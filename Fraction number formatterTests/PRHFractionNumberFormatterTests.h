//
//  PRHFractionNumberFormatterTests.h
//  Fraction number formatterTests
//
//  Created by Peter Hosey on 2013-05-02.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface PRHFractionNumberFormatterTests : SenTestCase

- (void) testParsingFractionWithPositiveComponents;
- (void) testParsingSingularNumber;
//Should return a negative number
- (void) testParsingFractionWithOneNegativeComponent;
//Should return a positive number
- (void) testParsingFractionWithTwoNegativeComponents;
//Should return 0.0
- (void) testParsingFractionWithZeroNumerator;
//Should return an error
- (void) testParsingFractionWithZeroDenominator;
- (void) testParsingPatentNonsense;

//Should return 0 over some non-zero number
- (void) testUnparsingFractionFromZero;
- (void) testUnparsingFractionFromPositiveFraction;
- (void) testUnparsingFractionFromNegativeFraction;
- (void) testUnparsingFractionFromPositiveInteger;
- (void) testUnparsingFractionFromNegativeInteger;
- (void) testUnparsingFractionFromPositiveOne;
- (void) testUnparsingFractionFromNegativeOne;
- (void) testUnparsingFractionFromPositiveSupraunaryFraction;
- (void) testUnparsingFractionFromNegativeSupraunaryFraction;

@end
