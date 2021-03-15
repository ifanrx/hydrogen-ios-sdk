//
//  ViewController.m
//  Demo_OC
//
//  Created by pengquanhua on 2019/4/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

#import "ViewController.h"

@import MinCloud;
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) BaaSTable *table;
@property (nonatomic, strong) BaaSContentGroup *contentGroup;
@property (nonatomic, strong) BaaSRecord *record;
@property (nonatomic, strong) BaaSFile *file;
@property (nonatomic, strong) BaaSCurrentUser *currentUser;
@property (nonatomic, strong) BaaSOrder *orderInfo;
@property (nonatomic, strong) BaaSFileManager *fileManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    NSString *filePath = [NSBundle.mainBundle pathForResource:@"datasource" ofType:@"plist"];
    self.datas = [NSArray arrayWithContentsOfFile:filePath];

    // 数据表
    _table = [[BaaSTable alloc] initWithName:@"Book"];

    _contentGroup = [[BaaSContentGroup alloc] initWithId: @"1551697162031508"];

    _fileManager = [[BaaSFileManager alloc] init];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSArray *array = self.datas[indexPath.section];
    cell.textLabel.text = array[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.datas[section];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datas.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
            case 0:
            return @"Auth";
            case 1:
            return @"User";
            case 2:
            return @"Table";
            case 3:
            return @"ContentGroup";
            case 4:
            return @"File";
            case 5:
            return @"Other";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_queue_t queue = dispatch_queue_create("com.mincloud.oc", DISPATCH_QUEUE_SERIAL);

    switch (indexPath.section) {
            case 0:
            switch (indexPath.row) {
                    case 0:
                    // 用户名注册
                {
                    [BaaSAuth registerWithUsername:@"test0703" password:@"111" callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 1:
                    // 邮箱注册
                {
                    [BaaSAuth registerWithEmail:@"test0703@ifanr.com" password:@"111" callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 2:
                    // 用户名登录
                {
                    [BaaSAuth loginWithUsername:@"ifanr_new" password:@"12345" callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 3:
                    // 邮箱登录
                {
                    [BaaSAuth loginWithEmail:@"test0703@ifanr.com" password:@"111" callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 4:
                    // 匿名登录
                {
                    [BaaSAuth anonymousLoginWithCallBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 5:
                    // 登出

                    [BaaSAuth logoutWithCallBackQueue:queue completion:^(BOOL resulst, NSError * _Nullable error) {
                        
                    }];
                    break;
                case 6:
                    // 微信登录
                {
                    [BaaSAuth signInWith:ProviderWechat createUser:YES syncUserProfile:SyncUserProfileTypeSetnx callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                case 7:
                    // 微信绑定
                {
                    [BaaSAuth associateWith:ProviderWechat syncUserProfile:SyncUserProfileTypeSetnx callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    
                case 8:
                    // 手机 + 验证码登录
                {
                    [BaaSAuth signInWithSMSVerificationCode:@"150****7274" code:@"281545" createUser:true callBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                default:
                    break;
            }
            break;
            case 1:
            switch (indexPath.row) {
                    case 0:
                    // 获取当前用户
                    //                    [BAASUser.currentUser getCurrentUserInfo:^(BOOL s, NSError * _Nullable error) {
                    //
                    //                    }];
                {
                    [BaaSAuth getCurrentUserWithCallBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }

                    break;
                    case 1:
                    // 更新用户名
                    [_currentUser updateUsername:@"testoc_new" callBackQueue:queue completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                    // 更新密码
                    [_currentUser updatePassword:@"111" newPassword:@"123" callBackQueue:queue completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 3:
                    // 更新邮箱
                    [_currentUser updateEmail:@"new_test041001@ifanr.com" sendVerification:YES callBackQueue:queue completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 4:
                    // 更新自定义用户信息
                    [_currentUser updateUserInfo:@{@"age": @22} callBackQueue:queue completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 5:
                    // 请求邮箱验证
                    [_currentUser requestEmailVerificationWithCallBackQueue:queue completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 6:
                    // 通过邮箱设置密码
                    [BaaSAuth resetPasswordWithEmail:@"new_test@ifanr.com" callBackQueue:queue completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 7:
                {
                    // 批量查询用户列表，如 获取年龄小于 25 的用户
                    BaaSWhere *where = [BaaSWhere compare:@"price" operator:BaaSOperatorLessThan value:@15];
                    BaaSQuery *query = [[BaaSQuery alloc] init];
                    [query setWhere:where];
                    [BaaSUser findWithQuery:query callBackQueue:queue completion:^(BaaSUserList * _Nullable listResult, NSError * _Nullable error) {

                    }];
                }
                    break;
                case 8:
                {
                    NSString *userId = @"36845069853014";
                    [BaaSUser get:userId select:@[@"nickname", @"gender"] expand:nil callBackQueue:queue completion:^(BaaSUser * _Nullable user, NSError * _Nullable error) {
                        
                    }];
                }
                    break;
                case 9:
                {
                    [BaaSAuth getCurrentUserWithCallBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        [currentUser updatePhone:@"150****7274" callBackQueue:queue completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {
                            NSLog(@"");
                        }];
                    }];
                }
                    break;
                    
                case 10:
                {
                    [BaaSAuth getCurrentUserWithCallBackQueue:queue completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        [currentUser verifyPhoneWithCode:@"123" callBackQueue:queue completion:^(BOOL success, NSError * _Nullable error) {
                            NSLog(@"");
                        }];
                    }];
                }
                    break;
                default:
                    break;
            }
            break;
            case 2:
            switch (indexPath.row) {
                    case 0:
                    // 获取指定数据详情

                    // 设置过滤字段
                    // [_table select:@[@"id", @"created_by"]];

                    // 设置扩展
                    // [_table expand:@[@"created_by"]];

                {
                    NSArray *select = @[@"color", @"created_by"];
                    NSArray *expand = @[@"created_by"];
                    [_table get:@"5ca47715d625d83705971cec" select:select expand:expand completion:^(BaaSRecord * _Nullable record, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 1:
                {

                    // 设置条件
                    BaaSQuery *query = [[BaaSQuery alloc] init];

                    // 指定返回结果起始位置
                    query.offset = 1;

                    // 指定返回结果个数
                    //[query limit:10];

                    // 过滤
                    //[query select:@[@"id"]];

                    // 扩展
                    //[query expand:@[@"created_by"]];

                    // 排序
                    //[query orderBy:@[@"-price", @"-off"]];

                    //设置查询条件
                    BaaSWhere *where = [BaaSWhere compare:@"price" operator:BaaSOperatorLessThan value:@20];
                    query.where = where;
                    query.returnTotalCount = YES;
                    query.limit = 10;
                    query.select = @[@"id"];
                    [_table findWithQuery:query completion:^(BaaSRecordList * _Nullable listResult, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 2:
                {
                    _record = [_table getWithoutDataWithRecordId:@"5ca45ee38c374f0864a80ff6"];
                    [_record set:@"color" value:@"brown"];
                    [_record set:@{@"author": @"hua", @"name": @"good book"}];
                    [_record incrementBy:@"price" value:@1];
                    [_record append:@"recommender" value:@[@"hong"]];
                    NSDictionary *options = @{RecordOptionKey.enableTrigger: @YES};
                    [_record updateWithExpand:nil options:options completion:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }
                    break;
                    case 3:
                    // 指定需要删除的记录
                    _record = [_table getWithoutDataWithRecordId:@"5ca46f00d625d806944bed3d"];
                    [_record deleteWithOptions:nil completion:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                    break;
                    case 4:
                {
                    // 批量删除，如删除所有 color 为 brown 的记录项。
                    BaaSWhere *where = [BaaSWhere contains:@"color" value:@"brown"];
                    BaaSQuery *query = [[BaaSQuery alloc] init];
                    query.where = where;
                    NSDictionary *options = @{RecordOptionKey.enableTrigger: @YES};
                    [_table deleteWithQuery:query options:options completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 5:
                {
                    _record = [_table createRecord];
                    // 逐个赋值
                    [_record set:@"color" value:@"red"];

                    // 一次性赋值
                    [_record set:@{@"price": @24, @"name": @"normal"}];

                    // geoPoint
                    BaaSGeoPoint *point = [[BaaSGeoPoint alloc] initWithLongitude:10 latitude:2];
                    [_record set:@"location" value:point];

                    // polygon
                    BaaSGeoPolygon *polygon = [[BaaSGeoPolygon alloc] initWithCoordinates:@[@[@10, @10], @[@40, @40], @[@20, @40], @[@10, @20], @[@10, @10]]];
                    [_record set:@"polygon" value:polygon];

                    // date
                    NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
                    NSString *dateISO = [dateFormatter stringFromDate:[NSDate date]];
                    [_record set:@"publish_date" value:dateISO];

                    [_record saveWithExpand:nil options:nil completion:^(BOOL success, NSError * _Nullable error) {
                                            
                    }];
                }
                    break;
                    case 6:
                {
                    // 批量增加数据
                    NSDictionary *options = @{RecordOptionKey.enableTrigger: @YES};
                    [_table createMany:@[@{@"name": @"bookname", @"price": @10}, @{@"name": @"bookname2", @"price": @11}] options:options completion:^(NSDictionary<NSString *,id> * _Nullable records, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 7:
                {
                    // 批量更新数据，如将价钱小于15的记录的价钱 增加 1.
                    BaaSWhere *where = [BaaSWhere compare:@"price" operator:BaaSOperatorLessThan value:@15];

                    BaaSQuery *query = [[BaaSQuery alloc] init];
                    [query setWhere:where];

                    NSDictionary *options = @{RecordOptionKey.enableTrigger: @YES};

                    BaaSRecord *record = [_table createRecord];
                    [record incrementBy:@"price" value:@1];

                    [_table updateWithRecord:record query:query options: options completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                case 8:
                {
                    
                    BaaSSubscription *subscription = nil;
                    BaaSTable *table = [[BaaSTable alloc] initWithName:@"danmu"];
                    BaaSWhere *where = [BaaSWhere compare:@"type" operator:BaaSOperatorEqualTo value:@"user"];
                    [table subscribe:BaaSSubscriptionEventOnCreate where:where onInit:^(BaaSSubscription * _Nonnull subscription) {
                        NSLog(@"订阅成功");
                    } onError:^(NSError * _Nullable error) {
                        NSLog(@"订阅错误：%@", error.localizedDescription);
                    } onEvent:^(NSDictionary<NSString *,id> * _Nullable result) {
                        NSLog(@"事件触发：%@", result);
                    }];
                }
                    break;
                case 9:
                {
                    BaaSSubscription *subscription = nil;

                    [subscription unsubscribeOnSuccess:^{
                        NSLog(@"取消订阅成功");
                    } onError:^(NSError * _Nullable error) {
                        NSLog(@"取消订阅错误：%@", error.localizedDescription);
                    }];
//                    [subscription unSubscribe:callbackQueue:nil onSuccess:^() {
//                        NSLog(@"订阅成功");
//                    } onError:^(NSError * _Nullable error) {
//                        NSLog(@"订阅错误：%@", error.localizedDescription);
//                    }];
                }
                    break;
                default:
                    break;
            }
            break;
            case 3:
            switch (indexPath.row) {
                    case 0:
                    // 获取内容详情
                    [_contentGroup get:@"1551697403189289" select:@[@"title"] completion:^(BaaSContent * _Nullable content, NSError * _Nullable error) {

                    }];
                    break;
                    case 1:
                    // 查询内容列表
                    // 如需查询，过滤，查找 Table的方法
                    [_contentGroup findWithQuery:nil completion:^(BaaSContentList * _Nullable listResult, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                    // 获取分类详情
                    [_contentGroup getCategory:@"1551697507400928" completion:^(BaaSContentCategory * _Nullable category, NSError * _Nullable error) {

                    }];
                    break;
                    case 4:
                    // 在分类中，查询内容列表
                    [_contentGroup getCategoryListWithQuery:nil completion:^(BaaSContentCategoryList * _Nullable listResult, NSError * _Nullable error) {

                    }];
                default:
                    break;
            }
            break;
            case 4:
            switch (indexPath.row) {
                    case 0:
                {
                    // 上传文件
                    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cover" ofType:@"png"];
                    NSData *fileData = [[NSData alloc] init];
                    [_fileManager uploadWithFilename:@"cover" fileData:fileData mimeType:@"image/png" categoryName:@"book" categoryId:nil progressBlock:^(NSProgress * _Nullable progress) {
                        
                    } completion:^(BaaSFile * _Nullable file, NSError * _Nullable error) {
                        
                    }];
                    break;
                }
                    case 1:
                    // 获取文件详情
                    [_fileManager get:@"5ca48a56d625d8365d972636" completion:^(BaaSFile * _Nullable file, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                {
                    // 获取文件列表
                    [_fileManager findWithQuery:nil completion:^(BaaSFileListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];

                }
                    break;
                    case 3:
                {
                    _file = [[BaaSFile alloc] init];
                    //_file.Id = @"5c7d05f75f2c5f2aa98395aa";
                    [_file delete:^(BOOL success, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 4:
                {
                    // 删除多个文件
                    [_fileManager delete:@[@"fileId"] completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 5:
                {
                    [_fileManager getCategory:@"5ca489bb8c374f5039a8062b" completion:^(BaaSFileCategory * _Nullable category, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 6:
                    [_fileManager getCategoryListWithQuery:nil completion:^(BaaSFileCategoryListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];
                    break;
                    case 7:
                    // 获取文件列表
                    [_fileManager findWithCategoryId:@"" query:nil completion:^(BaaSFileListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];
                    case 8:
                {
                    NSDictionary *params = @{
                            @"source": @"xxxxxxxxxx",
                            @"save_as": @"hello.png",
                            @"point": @"00:00:10",
                            @"category_id": @"5c18bc794e1e8d20dbfcddcc",
                            @"random_file_link": @NO };
                    [_fileManager genVideoSnapshot:params completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 9:
                {
                    NSDictionary *params = @{
                        @"m3u8s": @[@"xxxxxxxxxx", @"xxxxxxxxxx"],
                        @"save_as": @"hello.m3u8",
                        @"category_id": @"5c18bc794e1e8d20dbfcddcc",
                        @"random_file_link": @NO, };
                    [_fileManager videoConcat:params completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 10:
                {
                    NSDictionary *params = @{
                        @"m3u8": @"xxxxxxxxxx",
                        @"include": @[@0, @20],
                        @"save_as": @"0s_20s.m3u8",
                        @"category_id": @"5c18bc794e1e8d20dbfcddcc",
                        @"random_file_link": @NO };
                    [_fileManager videoClip:params completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 11:
                {
                    [_fileManager videoMeta:@"xxxx" completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 12:
                {
                    [_fileManager videoAudioMeta:@"xxxx" completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;

                default:
                    break;
            }
            break;
            case 5:
        {
            switch (indexPath.row) {
                case 0:
                    [BaaS invokeWithName:@"helloWorld" data:@{@"name": @"BaaS"} sync:YES callBackQueue:queue  completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                case 1:
                {
                    [BaaS sendSmsCodeWithPhone:@"150****7274" callBackQueue:queue completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                }
                    break;
                case 2:
                {
                    [BaaS verifySmsCodeWithPhone:@"150****7274" code:@"11111" callBackQueue:queue completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                }
                case 3:
                {
//                    [BaaS getServerTime:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
//
//                    }];
                    break;
                }
                default:
                    break;
            }
            break;

        }
            case 6:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSDictionary *options = @{PaymentOptionKey.merchandiseRecordID: @"123", PaymentOptionKey.merchandiseSchemaID: @"123", PaymentOptionKey.merchandiseSnapshot: @{}, PaymentOptionKey.profitSharing: @YES};
                    [BaaSPay.shared wxPayWithTotalCost:0.01 merchandiseDescription:@"微信支付" options:options completion:^(BaaSOrder * _Nullable orderInfo, NSError * _Nullable error) {

                        self.orderInfo = orderInfo;
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orderInfo.description];
                        }
                    }];
                }
                    break;
                case 1:
                {
                    [BaaSPay.shared aliPayWithTotalCost:0.01 merchandiseDescription:@"微信支付" options:nil completion:^(BaaSOrder * _Nullable orderInfo, NSError * _Nullable error) {

                        self.orderInfo = orderInfo;
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orderInfo.description];
                        }
                    }];
                }
                break;
                case 2:
                {
                    [BaaSPay.shared order:self.orderInfo.transactionNo completion:^(BaaSOrder * _Nullable orderInfo, NSError * _Nullable error) {
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orderInfo.description];
                        }
                    }];
                }
                    break;
                case 3:
                {
//                    [BaaSPay.shared repay:self.orderInfo completion:^(BaaSOrder * _Nullable orderInfo, NSError * _Nullable error) {
//                        if(error) {
//                            [self showMessage:error.localizedDescription];
//                        } else {
//                            [self showMessage:orderInfo.description];
//                        }
//                    }];
                }
                    break;
                case 4:
                {
                    [BaaSPay.shared orderListWithQuery:nil completion:^(BaaSOrderList * _Nullable orders, NSError * _Nullable error) {
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orders.description];
                        }

                        }];
                }
                break;
                case 5:
                {
                    BaaSOrderQuery *query = [[BaaSOrderQuery alloc] init];
                    query.status = BaaSOrderStatusPending;
                    [BaaSPay.shared orderListWithQuery:query completion:^(BaaSOrderList * _Nullable orders, NSError * _Nullable error) {
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orders.description];
                        }

                    }];
                }
                break;
                case 6:
                {
                    BaaSOrderQuery *query = [[BaaSOrderQuery alloc] init];
                    query.status = BaaSOrderStatusSuccess;
                    [BaaSPay.shared orderListWithQuery:query completion:^(BaaSOrderList * _Nullable orders, NSError * _Nullable error) {
                        if(error) {
                            [self showMessage:error.localizedDescription];
                        } else {
                            [self showMessage:orders.description];
                        }

                    }];
                }
                break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (void)showMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // 2.创建并添加按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
