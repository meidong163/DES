//
//  ViewController.m
//  DESEncrypt
//
//  Created by 舒江波 on 2019/4/24.
//  Copyright © 2019 com.pactera. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonCryptor.h>

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CBCEncrypt];
    NSLog(@"============分割线=================");
    [self EBCEncrypt];
    
}

- (void)CBCEncrypt
{
    NSString *plainText = @"我爱你中国 中国你好";
    NSString *key = @"11111111";
    // 加密
    NSData *enDataRes = [ViewController DESEncrypt:[plainText dataUsingEncoding:NSUTF8StringEncoding] WithKey:key];
    NSLog(@"%@",[enDataRes base64EncodedStringWithOptions:NSUTF8StringEncoding]);
    
    // 解密
    NSData *data = [[NSData alloc] initWithBase64EncodedString:@"05E11T6kkX7lspC7FPvPrSUhBVgux3slgy4rJSPXZHk=" options:0];
    NSData *deDataRes = [ViewController DESDecrypt:data WithKey:key];
    NSLog(@"%@",[[NSString alloc]initWithData:deDataRes encoding:NSUTF8StringEncoding]);
}

- (void)EBCEncrypt
{
    NSString *plainText = @"我爱你中国 中国你好";
    NSString *key = @"11111111";
    // 加密
    NSData *enDataRes = [ViewController DESDecryptEBC:[plainText dataUsingEncoding:NSUTF8StringEncoding] WithKey:key];
    NSLog(@"%@",[enDataRes base64EncodedStringWithOptions:NSUTF8StringEncoding]);
    
    // 解密
    NSData *data = [[NSData alloc] initWithBase64EncodedString:@"NXa2Un0Oav4AGE6MZVqgu2WHy5396DZHPd78Z9h2lME=" options:0];
    NSData *deDataRes = [ViewController DESDecryptEBC:data WithKey:key];
    NSLog(@"%@",[[NSString alloc]initWithData:deDataRes encoding:NSUTF8StringEncoding]);
}

#pragma mark - CBC

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{   // DES密钥参与运算的只有64位，超出的部分并不参与加密运算
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    NSData *keybyte = [key dataUsingEncoding:NSUTF8StringEncoding];
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeDES,
                                          [keybyte bytes],
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    NSData *keybyte = [key dataUsingEncoding:NSUTF8StringEncoding];
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeDES,
                                          [keybyte bytes],
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}


#pragma mark - EBC
+ (NSData *)DESEncryptEBC:(NSData *)data WithKey:(NSString *)key
{   // DES密钥参与运算的只有64位，超出的部分并不参与加密运算
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

+ (NSData *)DESDecryptEBC:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

@end
