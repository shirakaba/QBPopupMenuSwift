//- (void)drawArrowInRect:(CGRect)rect direction:(QBPopupMenuArrowDirection)direction highlighted:(BOOL)highlighted
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Border
//    CGContextSaveGState(context); {
//        CGRect arrowRect = CGRectZero;
//        switch (direction) {
//            case QBPopupMenuArrowDirectionDown:
//                arrowRect = CGRectMake(rect.origin.x, rect.origin.y - 0.6, rect.size.width, rect.size.height);
//                break;
//                
//            case QBPopupMenuArrowDirectionUp:
//                arrowRect = CGRectMake(rect.origin.x, rect.origin.y + 0.6, rect.size.width, rect.size.height);
//                break;
//                
//            case QBPopupMenuArrowDirectionLeft:
//                arrowRect = CGRectMake(rect.origin.x + 0.6, rect.origin.y - 0.5, rect.size.width, rect.size.height);
//                break;
//                
//            case QBPopupMenuArrowDirectionRight:
//                arrowRect = CGRectMake(rect.origin.x - 0.6, rect.origin.y - 0.5, rect.size.width, rect.size.height);
//                break;
//                
//            default:
//                break;
//        }
//        
//        CGMutablePathRef path = [self arrowPathInRect:arrowRect direction:direction];
//        CGContextAddPath(context, path);
//        
//        CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Highlight
//    CGContextSaveGState(context); {
//        CGRect arrowRect = CGRectZero;
//        switch (direction) {
//            case QBPopupMenuArrowDirectionUp:
//                arrowRect = CGRectMake(rect.origin.x, rect.origin.y + 2, rect.size.width, rect.size.height);
//                break;
//                
//            case QBPopupMenuArrowDirectionLeft:
//                arrowRect = CGRectMake(rect.origin.x + 2, rect.origin.y - 0.5 + 1, rect.size.width - 1, rect.size.height - 2);
//                break;
//                
//            case QBPopupMenuArrowDirectionRight:
//                arrowRect = CGRectMake(rect.origin.x - 1, rect.origin.y - 0.5 + 1, rect.size.width - 1, rect.size.height - 2);
//                break;
//                
//            default:
//                break;
//        }
//        
//        CGMutablePathRef path = [self arrowPathInRect:arrowRect direction:direction];
//        CGContextAddPath(context, path);
//        
//        if (highlighted) {
//            CGContextSetRGBFillColor(context, 0.384, 0.608, 0.906, 1.0);
//        } else {
//            CGContextSetRGBFillColor(context, 0.471, 0.471, 0.471, 1.0);
//        }
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Body
//    CGContextSaveGState(context); {
//        switch (direction) {
//            case QBPopupMenuArrowDirectionDown:
//            {
//                if (highlighted) {
//                    CGMutablePathRef path = [self arrowPathInRect:CGRectMake(rect.origin.x, rect.origin.y - 2, rect.size.width, rect.size.height) direction:direction];
//                    CGContextAddPath(context, path);
//                    CGContextClip(context);
//                    
//                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                    
//                    CGFloat components[8];
//                    components[0] = 0.027; components[1] = 0.169; components[2] = 0.733; components[3] = 1;
//                    components[4] = 0.020; components[5] = 0.114; components[6] = 0.675; components[7] = 1;
//                    
//                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//                    
//                    CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y - 2);
//                    CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
//                    
//                    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//                    
//                    CGGradientRelease(gradient);
//                    CGColorSpaceRelease(colorSpace);
//                    CGPathRelease(path);
//                }
//            }
//                break;
//                
//            case QBPopupMenuArrowDirectionUp:
//            {
//                CGMutablePathRef path = [self arrowPathInRect:CGRectMake(rect.origin.x + 1.4, rect.origin.y + 2 + 1.4, rect.size.width - 2.8, rect.size.height - 1.4) direction:direction];
//                CGContextAddPath(context, path);
//                CGContextClip(context);
//                
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                
//                CGFloat components[8];
//                if (highlighted) {
//                    components[0] = 0.290; components[1] = 0.580; components[2] = 1.000; components[3] = 1;
//                    components[4] = 0.216; components[5] = 0.471; components[6] = 0.871; components[7] = 1;
//                } else {
//                    components[0] = 0.401; components[1] = 0.401; components[2] = 0.401; components[3] = 1;
//                    components[4] = 0.314; components[5] = 0.314; components[6] = 0.314; components[7] = 1;
//                }
//                
//                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//                
//                CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y + 2);
//                CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
//                
//                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//                
//                CGGradientRelease(gradient);
//                CGColorSpaceRelease(colorSpace);
//                CGPathRelease(path);
//            }
//                break;
//                
//            case QBPopupMenuArrowDirectionLeft:
//            {
//                CGMutablePathRef path = [self arrowPathInRect:CGRectMake(rect.origin.x + 2, rect.origin.y - 0.5 + 2, rect.size.width - 1, rect.size.height - 2) direction:direction];
//                CGContextAddPath(context, path);
//                CGContextClip(context);
//                
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                
//                CGFloat components[16];
//                if (highlighted) {
//                    components[0]  = 0.082; components[1]  = 0.376; components[2]  = 0.859; components[3]  = 1;
//                    components[4]  = 0.004; components[5]  = 0.333; components[6]  = 0.851; components[7]  = 1;
//                    components[8]  = 0.000; components[9]  = 0.282; components[10] = 0.839; components[11] = 1;
//                    components[12] = 0.000; components[13] = 0.216; components[14] = 0.796; components[15] = 1;
//                } else {
//                    components[0]  = 0.216; components[1]  = 0.216; components[2]  = 0.216; components[3]  = 1;
//                    components[4]  = 0.165; components[5]  = 0.165; components[6]  = 0.165; components[7]  = 1;
//                    components[8]  = 0.102; components[9]  = 0.102; components[10] = 0.102; components[11] = 1;
//                    components[12] = 0.051; components[13] = 0.051; components[14] = 0.051; components[15] = 1;
//                }
//                
//                CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
//                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 4);
//                
//                CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y - 1);
//                CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
//                
//                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//                
//                CGGradientRelease(gradient);
//                CGColorSpaceRelease(colorSpace);
//                CGPathRelease(path);
//            }
//                break;
//                
//            case QBPopupMenuArrowDirectionRight:
//            {
//                CGMutablePathRef path = [self arrowPathInRect:CGRectMake(rect.origin.x - 1, rect.origin.y - 0.5 + 2, rect.size.width - 1, rect.size.height - 2) direction:direction];
//                CGContextAddPath(context, path);
//                CGContextClip(context);
//                
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                
//                CGFloat components[16];
//                if (highlighted) {
//                    components[0]  = 0.082; components[1]  = 0.376; components[2]  = 0.859; components[3]  = 1;
//                    components[4]  = 0.004; components[5]  = 0.333; components[6]  = 0.851; components[7]  = 1;
//                    components[8]  = 0.000; components[9]  = 0.282; components[10] = 0.839; components[11] = 1;
//                    components[12] = 0.000; components[13] = 0.216; components[14] = 0.796; components[15] = 1;
//                } else {
//                    components[0]  = 0.216; components[1]  = 0.216; components[2]  = 0.216; components[3]  = 1;
//                    components[4]  = 0.165; components[5]  = 0.165; components[6]  = 0.165; components[7]  = 1;
//                    components[8]  = 0.102; components[9]  = 0.102; components[10] = 0.102; components[11] = 1;
//                    components[12] = 0.051; components[13] = 0.051; components[14] = 0.051; components[15] = 1;
//                }
//                
//                CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
//                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 4);
//                
//                CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y - 1);
//                CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
//                
//                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//                
//                CGGradientRelease(gradient);
//                CGColorSpaceRelease(colorSpace);
//                CGPathRelease(path);
//            }
//                break;
//                
//            default:
//                break;
//        }
//    } CGContextRestoreGState(context);
//}
//
//- (void)drawHeadInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Border
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self headPathInRect:rect cornerRadius:cornerRadius];
//        CGContextAddPath(context, path);
//        
//        CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Highlight
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self headPathInRect:CGRectMake(rect.origin.x + 1, rect.origin.y + 1, rect.size.width - 1, rect.size.height - 2)
//cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        
//        if (highlighted) {
//            CGContextSetRGBFillColor(context, 0.384, 0.608, 0.906, 1.0);
//        } else {
//            CGContextSetRGBFillColor(context, 0.471, 0.471, 0.471, 1.0);
//        }
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Upper head
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self upperHeadPathInRect:CGRectMake(rect.origin.x + 1, rect.origin.y + 2, rect.size.width - 1, rect.size.height / 2 - 2) cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat components[8];
//        if (highlighted) {
//            components[0] = 0.216; components[1] = 0.471; components[2] = 0.871; components[3] = 1;
//            components[4] = 0.059; components[5] = 0.353; components[6] = 0.839; components[7] = 1;
//        } else {
//            components[0] = 0.314; components[1] = 0.314; components[2] = 0.314; components[3] = 1;
//            components[4] = 0.165; components[5] = 0.165; components[6] = 0.165; components[7] = 1;
//        }
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//        
//        CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y + 2);
//        CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2 - 2);
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//        
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Lower head
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self lowerHeadPathInRect:CGRectMake(rect.origin.x + 1, rect.origin.y + rect.size.height / 2, rect.size.width - 1, rect.size.height / 2 - 1) cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat components[8];
//        if (highlighted) {
//            components[0] = 0.047; components[1] = 0.306; components[2] = 0.827; components[3] = 1;
//            components[4] = 0.027; components[5] = 0.176; components[6] = 0.737; components[7] = 1;
//        } else {
//            components[0] = 0.102; components[1] = 0.102; components[2] = 0.102; components[3] = 1;
//            components[4] = 0;     components[5] = 0;     components[6] = 0;     components[7] = 1;
//        }
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//        
//        CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2);
//        CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 1);
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//        
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//}
//
//- (void)drawTailInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Border
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self tailPathInRect:rect cornerRadius:cornerRadius];
//        CGContextAddPath(context, path);
//        
//        CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Highlight
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self tailPathInRect:CGRectMake(rect.origin.x, rect.origin.y + 1, rect.size.width - 1, rect.size.height - 2) cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        
//        if (highlighted) {
//            CGContextSetRGBFillColor(context, 0.384, 0.608, 0.906, 1.0);
//        } else {
//            CGContextSetRGBFillColor(context, 0.471, 0.471, 0.471, 1.0);
//        }
//        CGContextFillPath(context);
//        
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Upper body
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self upperTailPathInRect:CGRectMake(rect.origin.x, rect.origin.y + 2, rect.size.width - 1, rect.size.height / 2 - 2) cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat components[8];
//        if (highlighted) {
//            components[0] = 0.216; components[1] = 0.471; components[2] = 0.871; components[3] = 1;
//            components[4] = 0.059; components[5] = 0.353; components[6] = 0.839; components[7] = 1;
//        } else {
//            components[0] = 0.314; components[1] = 0.314; components[2] = 0.314; components[3] = 1;
//            components[4] = 0.165; components[5] = 0.165; components[6] = 0.165; components[7] = 1;
//        }
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//        
//        CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y + 2);
//        CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2 - 2);
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//        
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//    
//    // Lower body
//    CGContextSaveGState(context); {
//        CGMutablePathRef path = [self lowerTailPathInRect:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height / 2, rect.size.width - 1, rect.size.height / 2 - 1) cornerRadius:cornerRadius - 1];
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat components[8];
//        if (highlighted) {
//            components[0] = 0.047; components[1] = 0.306; components[2] = 0.827; components[3] = 1;
//            components[4] = 0.027; components[5] = 0.176; components[6] = 0.737; components[7] = 1;
//        } else {
//            components[0] = 0.102; components[1] = 0.102; components[2] = 0.102; components[3] = 1;
//            components[4] = 0;     components[5] = 0;     components[6] = 0;     components[7] = 1;
//        }
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//        
//        CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2);
//        CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 1);
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
//        
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//        CGPathRelease(path);
//    } CGContextRestoreGState(context);
//}

