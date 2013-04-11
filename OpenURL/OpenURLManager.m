//
//  OpenURLManager.m
//  OpenURLDemo
//
//  Created by shaowei on 13-4-11.
//  Copyright (c) 2013年 LianZhan. All rights reserved.
//

#import "OpenURLManager.h"

@implementation OpenURLManager

#pragma mark Function - Private

/**
 用于弹出警告提示信息
 @param title:警告框的标题
 @param content:警告框显示的提示性内容
 */

+ (void)showAlertTitle:(NSString *)title andContent:(NSString *)content{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:content
                                                delegate:nil
                                       cancelButtonTitle:@"确定"
                                       otherButtonTitles:nil, nil];
    [av show];
    [av release];
}

/**
 调用电话
 @param phoneNumber:需要拨打的电话
 */
+ (void)callTelWithPhoneNumber:(NSString *)phoneNumber{
    UIApplication *app =[UIApplication sharedApplication];
    NSString *fullString = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    NSURL *url = [NSURL URLWithString:fullString];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }else{
        //手机客户端不支持此功能
        [OpenURLManager showAlertTitle:@"不能电话功能"
                            andContent:@"您的设备可能不支持电话功能"];
    }
}


/**
 调用邮件客户端
 @param email:您要发送邮件的接收方的邮件地址
 */
+ (void)callEmailWithemail:(NSString *)email {
    UIApplication *app =[UIApplication sharedApplication];
    NSString *fullString = [NSString stringWithFormat:@"mailto://%@",email];
    NSURL *url = [NSURL URLWithString:fullString];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }else{
        //手机客户端不支持此功能
        [OpenURLManager showAlertTitle:@"不能打开邮件客户端"
                            andContent:@"您的设备可能不支持邮件功能"];
    }
    
}

/**
 调用浏览器
 @param email:您要发送邮件的接收方的邮件地址
 */
+ (void)callWebBrowserWithURL:(NSString *)urlString{
    UIApplication *app =[UIApplication sharedApplication];
    
    //为用户增加http前缀
    if ([urlString hasPrefix:@"www"]) {
        urlString = [NSString stringWithFormat:@"http://%@",urlString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }else{
        //手机客户端不支持此功能
        [OpenURLManager showAlertTitle:@"不能打开该网站"
                            andContent:@"您的网址可能不正确"];
    }
}

/**
 调用Map客户端 显示用户当前位置到指定位置的驾车路线
 @param desCoordinate:目的地的经纬度（注意：纬度在前，经度在后）
 @param desName:目的地标识显示的文字信息，默认值为“目的地”
 */
+ (void)callMapShowPathFromCurrentLocationTo:(CLLocationCoordinate2D)desCoordinate andDesName:(NSString *)desName{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0f) {
        //ios_version为4.0～5.1时 调用谷歌地图客户端
        
        //生成url字符串
        NSString *currentLocation = [LocalizedCurrentLocation currentLocationStringForCurrentLanguage];
        NSString *desLocation = [NSString stringWithFormat:@"%f,%f",
                                         desCoordinate.latitude,
                                         desCoordinate.longitude];
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@",
                               currentLocation,desLocation];
        //转换为utf8编码
        urlString =  [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
        UIApplication *app =[UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:urlString];
        
        //验证url是否可用
        if ([app canOpenURL:url]) {
            [app openURL:url];
        }else{
            //手机客户端不支持此功能 或者 目的地有误
            [OpenURLManager showAlertTitle:@"不能打开该地址"
                                andContent:@"您输入的位置可能有误"];
        }
        
    }else{
        //ios_version为 >=6.0时 调用苹果地图客户端
        
        //验证MKMapItem的有效性
        Class itemClass = [MKMapItem class];
        if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
            desName = desName?desName:@"目的地";
            NSDictionary *dicOfAddress = [NSDictionary dictionaryWithObjectsAndKeys:
                                          desName,(NSString *)kABPersonAddressStreetKey, nil];
            MKPlacemark *palcemake = [[MKPlacemark alloc] initWithCoordinate:desCoordinate addressDictionary:dicOfAddress];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:palcemake];
            
            NSDictionary *dicOfMode = [NSDictionary dictionaryWithObjectsAndKeys:
                                       MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsDirectionsModeKey, nil];
            //打开客户端
            if (![mapItem openInMapsWithLaunchOptions:dicOfMode]) {
                //打开失败
                [OpenURLManager showAlertTitle:@"不能打开该地址"
                                    andContent:@"您输入的位置可能有误"];
            }
        }
        
    }
    
}





@end
