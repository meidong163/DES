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
    
    [self EncryptFile];
    NSLog(@"============分割线=================");
//    [self decryptFile];
//    [self fileReadWrite];// 读写文件是没有问题的，加密之后会会破坏zip文件的格式导致文件无法正常解压
}

- (void)fileReadWrite
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:@"zip"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSString *cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // www.zip 解压到的沙盒目录
        NSString *dirPath = [cacheFilePath stringByAppendingPathComponent:@"readwrite/www.zip"];
        NSLog(@"沙盒目录：%@",dirPath);
        NSError *err = nil;
        if ([self.class createFileAtPath:dirPath overwrite:YES error:&err]) {// 创建文件成功
            if ([fileData writeToFile:dirPath atomically:YES]) {
                NSLog(@"文件写成功");
            }
        }
    });
}

- (void)EncryptFile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:@"zip"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        // 对文件加密 密钥为11111111
        NSData *encryptFile = [self.class DESEncrypt:fileData WithKey:@"11111111"];
        // 加密之后的对象写到沙盒文件
        
        NSString  *cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // www.zip 解压到的沙盒目录
        NSString *dirPath = [cacheFilePath stringByAppendingPathComponent:@"app/wwwencrypt.zip"];
        NSLog(@"沙盒目录：%@",dirPath);
        NSError *err = nil;
        if ([self.class createFileAtPath:dirPath overwrite:YES error:&err]) {// 创建文件成功
            BOOL flag = [encryptFile writeToFile:dirPath options:NSDataWritingAtomic error:&err];
            if (err) {
                NSLog(@"error = %@",err);
                return ;
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (flag) {
                        NSLog(@"文件加密成功");
                        [self decryptFile];
                    }
                });
            }
        }else NSLog(@"创建文件失败");
        
    });
}

- (void)decryptFile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString  *cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dirPath = [cacheFilePath stringByAppendingPathComponent:@"app/wwwencrypt.zip"];
        NSLog(@"解密目标文件路：%@",dirPath);
        NSData *decryptFile = [self.class DESDecrypt:[NSData dataWithContentsOfFile:dirPath] WithKey:@"11111111"];
        NSString *decryptDirPath = [cacheFilePath stringByAppendingPathComponent:@"decrypt/www.zip"];
        NSError *err = nil;
        if ([self.class createFileAtPath:decryptDirPath overwrite:YES error:&err]) {
            if ([decryptFile writeToFile:decryptDirPath options:NSDataWritingAtomic error:&err]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   NSLog(@"文件解密成功 %@",decryptDirPath);
                });
            }else NSLog(@"文件解密失败 error = %@",err);
        }else NSLog(@"创建文件失败 error = %@",err);
        
    });
    
}

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    /* createDirectoryAtPath:withIntermediateDirectories:attributes:error:
     * 参数1：创建的文件夹的路径
     * 参数2：是否创建媒介的布尔值，一般为YES
     * 参数3: 属性，没有就置为nil
     * 参数4: 错误信息
    */
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

/*创建文件
 *参数1：文件创建的路径
 *参数2：写入文件的内容
 *参数3：假如已经存在此文件是否覆盖
 *参数4：错误信息
 */
+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self directoryAtPath:path];
    if (![self isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self isExistsAtPath:path]) {
            return YES;
        }
    }
   /*创建文件
    *参数1：创建文件的路径
    *参数2：创建文件的内容（NSData类型）
    *参数3：文件相关属性
    */
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];

    return isSuccess;
}

+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *)directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
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
