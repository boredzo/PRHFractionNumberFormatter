//
//  PRHFractionNumberFormatter.m
//  Fraction number formatter
//
//  Created by Peter Hosey on 2013-05-02.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#include <stdbool.h>
#include <tgmath.h>
#import <Foundation/Foundation.h>

#import "PRHFractionNumberFormatter.h"

static void getFraction(double fraction, double *outNum, double *outDenom, bool verbose);

@interface PRHFractionNumberFormatter ()
- (NSNumber *) numberFromRangeAtIndex:(NSUInteger)i
                             ofResult:(NSTextCheckingResult *)result
                           fromString:(NSString *)string;

- (NSError *) formattingErrorWithDescription:(NSString *)errorDescription;
@end

@implementation PRHFractionNumberFormatter
{
	NSRegularExpression *_fractionRegularExpression;
}

- (NSString *) stringFromNumber:(NSNumber *)number {
	double numerator, denominator;
	getFraction([number doubleValue], &numerator, &denominator, false);
	return [NSString stringWithFormat:@"%ld/%ld", (long)numerator, (long)denominator];
}

- (NSNumber *) numberFromString:(NSString *)string {
	NSNumber *number = nil;
	[self getObjectValue:&number forString:string range:NULL error:NULL];
	return number;
}

- (BOOL) getObjectValue:(id *)obj forString:(NSString *)string range:(NSRange *)outRange error:(out NSError **)outError {
	double numerator = 0.0;
	double denominator = 0.0;
	NSRange fractionRange;
	bool parsed = [self parseString:string intoNumerator:&numerator andDenominator:&denominator fractionRange:&fractionRange];
	if (!parsed) {
		//It's not a fraction, so let our superclass try the usual number-parsing machinery in case it's a singular number.
		@try {
			return [super getObjectValue:obj forString:string range:outRange error:outError];
		} @catch (NSException *exc) {
			*outError = [self formattingErrorWithDescription:@"Could not parse this string, neither as a fraction nor as a singular number"];
			return NO;
		}
	}

	if (denominator == 0.0) {
		if (outError != NULL)
			*outError = [self formattingErrorWithDescription:@"Can't create number from fraction with zero denominator (divide by zero)"];
		return NO;
	}

	if (obj != NULL)
		*obj = @(numerator / denominator);
	if (outRange != NULL)
		*outRange = fractionRange;

	return YES;
}

- (bool) parseString:(NSString *)string
       intoNumerator:(double *)outNumerator
	  andDenominator:(double *)outDenominator
       fractionRange:(out NSRange *)outRange
{
#define SIGNED_DECIMAL_NUMBER_REGEX @"[-+0-9.]+"
#define SIGNED_DECIMAL_NUMBER_REGEX_GROUP @"(" SIGNED_DECIMAL_NUMBER_REGEX @")"
	if (_fractionRegularExpression == NULL) {
		NSString *pattern = SIGNED_DECIMAL_NUMBER_REGEX_GROUP @"/" SIGNED_DECIMAL_NUMBER_REGEX_GROUP;
		_fractionRegularExpression = [NSRegularExpression regularExpressionWithPattern:pattern
			options:(NSRegularExpressionOptions)0
			error:NULL];
	}

	NSTextCheckingResult *result = [_fractionRegularExpression firstMatchInString:string
		options:outRange == NULL ? NSMatchingAnchored : (NSMatchingOptions)0
		range:(NSRange){ 0, string.length }];

	NSRange resultRange = result ? result.range : (NSRange){ NSNotFound, 0 };
	if (outRange != NULL)
		*outRange = resultRange;

	if (resultRange.location == NSNotFound)
		return false;

	if (outNumerator != NULL) {
		NSNumber *number = [self numberFromRangeAtIndex:1
				ofResult:result
				fromString:string];
		*outNumerator = [number doubleValue];
	}
	if (outDenominator != NULL) {
		NSNumber *number = [self numberFromRangeAtIndex:2
		                                       ofResult:result
				                             fromString:string];
		*outDenominator = [number doubleValue];
	}

	return true;
}

- (NSNumber *) numberFromRangeAtIndex:(NSUInteger)i
	ofResult:(NSTextCheckingResult *)result
	fromString:(NSString *)string
{
	NSRange range = [result rangeAtIndex:i];
	NSString *substring = [string substringWithRange:range];
	NSNumber *number = [self numberFromString:substring];
	return number;
}

- (NSError *) formattingErrorWithDescription:(NSString *)errorDescription {
	return [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:@{
		NSLocalizedDescriptionKey: NSLocalizedString(errorDescription, @"Description of error in formatting or parsing a fraction")
	}];
}

@end

//Migrated from https://bitbucket.org/boredzo/getfract
static void getFraction(double fraction, double *outNum, double *outDenom, bool verbose) {
	int is_negative = signbit(fraction) != 0;
	if(is_negative) fraction = fabs(fraction);

	//Start at one-half.
	double num = 1.0, denom = 2.0;

	//Special-case: Bail on zero.
	if(fraction < DBL_EPSILON) {
		num = 1.0;
		denom = INFINITY;
	} else {
		double test;
		while((test = num / denom) != fraction) {
			if (verbose) printf("%lu/%lu = %f\n", (unsigned long)num, (unsigned long)denom, test);
			if(test < fraction)
				num += 1.0;
			else
				denom += 1.0;
		}
	}

	if(is_negative) num = -num; //Or we could do this to denominator. It doesn't matter which, just so long as we negate only one and not the other.

	if(outNum)
		*outNum = num;
	if(outDenom)
		*outDenom = denom;
}
