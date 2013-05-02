//
//  PRHFractionNumberFormatter.h
//  Fraction number formatter
//
//  Created by Peter Hosey on 2013-05-02.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRHFractionNumberFormatter : NSNumberFormatter

//If outRange is NULL, string must entirely be a fraction. If it is non-NULL, string may be any string that contains a fraction, and the returned values represent the first fraction found.
- (bool) parseString:(NSString *)string
       intoNumerator:(double *)outNumerator
	  andDenominator:(double *)outDenominator
       fractionRange:(out NSRange *)outRange;

@end
