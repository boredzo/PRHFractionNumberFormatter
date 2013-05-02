//
//  PRHFractionNumberFormatterTests.m
//  Fraction number formatterTests
//
//  Created by Peter Hosey on 2013-05-02.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#include <stdbool.h>

#import "PRHFractionNumberFormatterTests.h"
#import "PRHFractionNumberFormatter.h"

@interface PRHFractionNumberFormatterTests ()
- (void) assertThatParsingString:(NSString *)string returnsValue:(double)expectedValue;
- (void) assertThatParsingStringReturnsError:(NSString *)string;
@end

@implementation PRHFractionNumberFormatterTests
{
	PRHFractionNumberFormatter *_fractionNumberFormatter;
}

- (void) setUp {
	[super setUp];

	_fractionNumberFormatter = [[PRHFractionNumberFormatter alloc] init];
}

- (void) tearDown {
	_fractionNumberFormatter = nil;

	[super tearDown];
}

- (void) assertThatParsingString:(NSString *)string returnsValue:(double)expectedValue {
	NSNumber *number = [_fractionNumberFormatter numberFromString:string];
	STAssertNotNil(number, @"Parsing a fraction (%@) should return an object", string);
	STAssertTrue([number isKindOfClass:[NSNumber class]], @"Parsing a fraction (%@) should return an NSNumber", string);
	STAssertEquals([number doubleValue], expectedValue, @"Parsing %@ should return %g", string, expectedValue);
}

- (void) assertThatParsingStringReturnsError:(NSString *)string {
	NSNumber *number = nil;
	NSRange range;
	NSError *error = nil;
	BOOL success = [_fractionNumberFormatter getObjectValue:&number forString:string range:&range error:&error];
	STAssertFalse(success, @"Parsing a bogus string should return false, not %d", (int)success);
	STAssertNotNil(error, @"Parsing a bogus string should return an error");
	STAssertNil(number, @"Parsing a bogus string should not return a number (got %@)", number);
}

- (void) testParsingSingularNumber {
	double expectedValue;

	expectedValue = 42.0;
	[self assertThatParsingString:@"42" returnsValue:expectedValue];
	[self assertThatParsingString:@"42.0" returnsValue:expectedValue];

	expectedValue = -42.0;
	[self assertThatParsingString:@"-42" returnsValue:expectedValue];
	[self assertThatParsingString:@"-42.0" returnsValue:expectedValue];
}

- (void) testParsingFractionWithPositiveComponents {
	double expectedValue = 4.0 / 5.0;
	[self assertThatParsingString:@"4/5" returnsValue:expectedValue];
	[self assertThatParsingString:@"4.0/5.0" returnsValue:expectedValue];
}

- (void) testParsingFractionWithOneNegativeComponent {
	double expectedValue;
	expectedValue = 4.0 / -5.0;
	[self assertThatParsingString:@"4/-5" returnsValue:expectedValue];
	[self assertThatParsingString:@"4.0/-5.0" returnsValue:expectedValue];

	expectedValue = -4.0 / 5.0;
	[self assertThatParsingString:@"-4/5" returnsValue:expectedValue];
	[self assertThatParsingString:@"-4.0/5.0" returnsValue:expectedValue];
}

- (void) testParsingFractionWithTwoNegativeComponents {
	//Should produce the same results as testParsingFractionWithPositiveComponents.
	double expectedValue = -4.0 / -5.0;
	[self assertThatParsingString:@"-4/-5" returnsValue:expectedValue];
	[self assertThatParsingString:@"-4.0/-5.0" returnsValue:expectedValue];
}

- (void) testParsingFractionWithZeroNumerator {
	double expectedValue = 0.0 / 5.0;
	[self assertThatParsingString:@"0/5" returnsValue:expectedValue];
	[self assertThatParsingString:@"0.0/5.0" returnsValue:expectedValue];
}

- (void) testParsingFractionWithZeroDenominator {
	[self assertThatParsingStringReturnsError:@"4/0"];
	[self assertThatParsingStringReturnsError:@"4/0.0"];
	[self assertThatParsingStringReturnsError:@"4.0/0"];
	[self assertThatParsingStringReturnsError:@"4.0/0.0"];
	[self assertThatParsingStringReturnsError:@"-4/0"];
	[self assertThatParsingStringReturnsError:@"-4/0.0"];
	[self assertThatParsingStringReturnsError:@"-4.0/0"];
	[self assertThatParsingStringReturnsError:@"-4.0/0.0"];

	[self assertThatParsingStringReturnsError:@"4/-0"];
	[self assertThatParsingStringReturnsError:@"4/-0.0"];
	[self assertThatParsingStringReturnsError:@"4.0/-0"];
	[self assertThatParsingStringReturnsError:@"4.0/-0.0"];
	[self assertThatParsingStringReturnsError:@"-4/-0"];
	[self assertThatParsingStringReturnsError:@"-4/-0.0"];
	[self assertThatParsingStringReturnsError:@"-4.0/-0"];
	[self assertThatParsingStringReturnsError:@"-4.0/-0.0"];
}

- (void) testParsingPatentNonsense {
	[self assertThatParsingStringReturnsError:@"I am the very model of a modern Major-General"];
	[self assertThatParsingStringReturnsError:@"/"];
	[self assertThatParsingStringReturnsError:@"-/-"];
	[self assertThatParsingStringReturnsError:@"+/+"];
	[self assertThatParsingStringReturnsError:@"-/+"];
	[self assertThatParsingStringReturnsError:@"+/-"];
	[self assertThatParsingStringReturnsError:@"-./-."];
	[self assertThatParsingStringReturnsError:@"+./+."];
	[self assertThatParsingStringReturnsError:@"-./+."];
	[self assertThatParsingStringReturnsError:@"+./-."];
}

- (void) testUnparsingFractionFromZero {
	NSNumber *number = @0.0;
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
		intoNumerator:&numerator
		andDenominator:&denominator
		fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(numerator, 0.0, @"Numerator of fraction (%g/%g) generated from zero should be zero", numerator, denominator);
	STAssertFalse(denominator == 0.0, @"Denominator of fraction (%g/%g) generated from zero should not be zero", numerator, denominator);
}

- (void) testUnparsingFractionFromPositiveFraction {
	NSNumber *number = @(2.0/3.0);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(numerator, 2.0, @"Numerator of fraction generated from two-thirds should be two");
	STAssertEquals(denominator, 3.0, @"Denominator of fraction generated from two-thirds should be three");
	STAssertFalse(signbit(numerator) || signbit(denominator), @"Neither of the components of the fraction generated from positive number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromNegativeFraction {
	NSNumber *number = @(-(2.0/3.0));
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), 2.0, @"Absolute value of numerator of fraction generated from negative two-thirds should be two");
	STAssertEquals(fabs(denominator), 3.0, @"Absolute value of denominator of fraction generated from negative two-thirds should be three");
	STAssertTrue(((bool)signbit(numerator)) ^ ((bool)signbit(denominator)), @"Exactly one of the components of the fraction generated from negative two-thirds should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromPositiveInteger {
	double value = 42.0;
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), fabs(value), @"Numerator of fraction generated from whole number should be that number");
	STAssertEquals(fabs(denominator), 1.0, @"Denominator of fraction generated from whole number should be one");
	STAssertFalse(signbit(numerator) || signbit(denominator), @"Neither of the components of the fraction generated from positive number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromNegativeInteger {
	double value = -42.0;
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), fabs(value), @"Numerator of fraction generated from whole number should be that number");
	STAssertEquals(fabs(denominator), 1.0, @"Denominator of fraction generated from whole number should be one");
	STAssertTrue(((bool)signbit(numerator)) ^ ((bool)signbit(denominator)), @"Exactly one of the components of the fraction generated from negative number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromPositiveOne {
	double value = 1.0;
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), fabs(value), @"Numerator of fraction generated from whole number should be that number");
	STAssertEquals(fabs(denominator), 1.0, @"Denominator of fraction generated from whole number should be one");
	STAssertFalse(signbit(numerator) || signbit(denominator), @"Neither of the components of the fraction generated from positive number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromNegativeOne {
	double value = -1.0;
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), fabs(value), @"Numerator of fraction generated from whole number should be that number");
	STAssertEquals(fabs(denominator), 1.0, @"Denominator of fraction generated from whole number should be one");
	STAssertTrue(((bool)signbit(numerator)) ^ ((bool)signbit(denominator)), @"Exactly one of the components of the fraction generated from negative number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromPositiveSupraunaryFraction {
	double expectedNumerator = 42.0;
	double expectedDenominator = 5.0;
	double value = expectedNumerator / expectedDenominator;
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), expectedNumerator, @"Wrong numerator in fraction generated from improper fraction");
	STAssertEquals(fabs(denominator), expectedDenominator, @"Wrong denominator in fraction generated from improper fraction");
	STAssertFalse(signbit(numerator) || signbit(denominator), @"Neither of the components of the fraction generated from positive number should be negative; instead, got %g and %g", numerator, denominator);
}

- (void) testUnparsingFractionFromNegativeSupraunaryFraction {
	double expectedNumerator = 42.0;
	double expectedDenominator = 5.0;
	double value = -(expectedNumerator / expectedDenominator);
	NSNumber *number = @(value);
	NSString *string = [_fractionNumberFormatter stringFromNumber:number];

	double numerator = 0.0;
	double denominator = 0.0;
	bool parsed = [_fractionNumberFormatter parseString:string
	                                      intoNumerator:&numerator
				                         andDenominator:&denominator
							              fractionRange:NULL];
	STAssertTrue(parsed, @"Generating a fraction from %@ should succeed", number);
	STAssertEquals(fabs(numerator), expectedNumerator, @"Wrong numerator in fraction generated from improper fraction");
	STAssertEquals(fabs(denominator), expectedDenominator, @"Wrong denominator in fraction generated from improper fraction");
	STAssertTrue(((bool)signbit(numerator)) ^ ((bool)signbit(denominator)), @"Exactly one of the components of the fraction generated from negative number should be negative; instead, got %g and %g", numerator, denominator);
}

@end
