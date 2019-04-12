//
//  H5Controller.h
//  H5InApp
//
//  Created by Sunny on 12/4/19.
//  Copyright © 2019年 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface H5Controller : UIViewController

@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString * fileUrl;

-(instancetype)initWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
