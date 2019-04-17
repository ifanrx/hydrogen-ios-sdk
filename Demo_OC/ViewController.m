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
@property (nonatomic, strong) BaaSUserManager *userManager;
@property (nonatomic, strong) BaaSTable *table;
@property (nonatomic, strong) BaaSContentGroup *contentGroup;
@property (nonatomic, strong) BaaSFileManager *fileManager;
@property (nonatomic, strong) BaaSRecord *record;
@property (nonatomic, strong) BaaSFile *file;
@property (nonatomic, strong) BaaSCurrentUser *currentUser;
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

    _userManager = [[BaaSUserManager alloc] init];

    // 数据表
    _table = [[BaaSTable alloc] initWithName:@"Book"];

    _contentGroup = [[BaaSContentGroup alloc] initWithId: 1551697162031508];

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
    switch (indexPath.section) {
            case 0:
            switch (indexPath.row) {
                    case 0:
                    // 用户名注册
                {
                    [BaaSAuth registerWithUsername:@"test04101" password:@"111" completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 1:
                    // 邮箱注册
                {
                    [BaaSAuth registerWithEmail:@"test04101@ifanr.com" password:@"111" completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 2:
                    // 用户名登录
                {
                    [BaaSAuth loginWithUsername:@"test04101" password:@"111" completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 3:
                    // 邮箱登录
                {
                    [BaaSAuth loginWithEmail:@"test04101@ifanr.com" password:@"111" completion:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 4:
                    // 匿名登录
                {
                    [BaaSAuth anonymousLogin:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }
                    break;
                    case 5:
                    // 登出

                    [BaaSAuth logout:^(BOOL success, NSError * _Nullable error) {

                    }];
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
                    [BaaSAuth getCurrentUser:^(BaaSCurrentUser * _Nullable currentUser, NSError * _Nullable error) {
                        self.currentUser = currentUser;
                    }];
                }

                    break;
                    case 1:
                    // 更新用户名
                    [_currentUser updateUsername:@"testoc_new" completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                    // 更新密码
                    [_currentUser updatePassword:@"111" newPassword:@"123" completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 3:
                    // 更新邮箱
                    [_currentUser updateEmail:@"new_test041001@ifanr.com" sendVerification:YES completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 4:
                    // 更新自定义用户信息
                    [_currentUser updateUserInfo:@{@"age": @22} completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                    break;
                    case 5:
                    // 请求邮箱验证
                    [_currentUser requestEmailVerification:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 6:
                    // 通过邮箱设置密码
                    [_currentUser resetPasswordWithEmail:@"new_test@ifanr.com" completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 7:
                {
                    // 批量查询用户列表，如 获取年龄小于 25 的用户
                    BaaSWhere *where = [BaaSWhere compareWithKey:@"price" operator:BaaSOperatorLessThan value:@15];
                    BaaSQuery *query = [[BaaSQuery alloc] init];
                    [query setWhere:where];
                    [BaaSUserManager findWithQuery:query completion:^(BaaSUserListResult * _Nullable listResult, NSError * _Nullable error) {

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
                    [query offset:1];

                    // 指定返回结果个数
                    //[query limit:10];

                    // 过滤
                    //[query select:@[@"id"]];

                    // 扩展
                    //[query expand:@[@"created_by"]];

                    // 排序
                    //[query orderBy:@[@"-price", @"-off"]];

                    //设置查询条件
                    BaaSWhere *where = [BaaSWhere compareWithKey:@"price" operator:BaaSOperatorLessThan value:@20];
                    [query setWhere:where];
                    [_table findWithQuery:query completion:^(BaaSRecordListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 2:

                    _record = [_table getWithoutDataWithRecordId:@"5ca45ee38c374f0864a80ff6"];
                    [_record setWithKey:@"color" value:@"brown"];
                    [_record setWithRecord:@{@"author": @"hua", @"name": @"good book"}];
                    [_record incrementByKey:@"price" value:@1];
                    [_record appendWithKey:@"recommender" value:@[@"hong"]];
                    [_record update:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 3:
                    // 指定需要删除的记录
                    _record = [_table getWithoutDataWithRecordId:@"5ca46f00d625d806944bed3d"];
                    [_record deleteWithCompletion:^(BOOL success, NSError * _Nullable error) {

                    }];
                    break;
                    case 4:
                {
                    // 批量删除，如删除所有 color 为 brown 的记录项。
                    BaaSWhere *where = [BaaSWhere containsWithKey:@"color" value:@"brown"];
                    BaaSQuery *query = [[BaaSQuery alloc] init];
                    [query setWhere:where];
                    NSDictionary *options = @{@"": @true};
                    [_table deleteWithQuery:query options:options completion:^(NSDictionary<NSString *,id> * _Nullable result, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 5:
                {
                    _record = [_table createRecord];
                    // 逐个赋值
                    [_record setWithKey:@"color" value:@"red"];

                    // 一次性赋值
                    [_record setWithRecord:@{@"price": @24, @"name": @"normal"}];

                    // geoPoint
                    BAASGeoPoint *point = [[BAASGeoPoint alloc] initWithLatitude:10 longitude:2];
                    [_record setWithKey:@"location" value:point.geoJson];

                    // polygon
                    BAASGeoPolygon *polygon = [[BAASGeoPolygon alloc] initWithCoordinates:@[@[@30, @10], @[@40, @40], @[@20, @40], @[@10, @20], @[@30, @10]]];
                    [_record setWithKey:@"polygon" value:polygon.geoJson];

                    // date
                    NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
                    NSString *dateISO = [dateFormatter stringFromDate:[NSDate date]];
                    [_record setWithKey:@"" value:dateISO];

                    [_record save:^(BOOL success, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 6:
                {
                    // 批量增加数据
                    NSDictionary *options = @{@"enable_trigger": @YES};
                    [_table createMany:@[@{@"name": @"bookname", @"price": @10}, @{@"name": @"bookname2", @"price": @11}] options:options completion:^(NSDictionary<NSString *,id> * _Nullable records, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 7:
                {
                    //                    // 批量更新数据，如将价钱小于15的记录的价钱 增加 1.
                    //                    BAASQuery *query = [BAASQuery compareWithKey:@"price" operator:BAASOperatorLessThan value:@15];
                    //                    [_table setQuery:query];
                    //
                    //                    BAASTableRecord *record = [_table createRecord];
                    //                    [record incrementByKey:@"price" value:@1];
                    //
                    //                    [_table update:record enableTrigger:true completion:^(NSDictionary<NSString *,id> * _Nullable records, NSError * _Nullable error) {
                    //
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
                    [_contentGroup get:1551697403189289 select:@[@"title"] expand:nil completion:^(BaaSContent * _Nullable content, NSError * _Nullable error) {

                    }];
                    break;
                    case 1:
                    // 查询内容列表
                    // 如需查询，过滤，查找 Table的方法
                    [_contentGroup findWithQuery:nil completion:^(BaaSContentListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                    // 获取分类详情
                    [_contentGroup getCategory:@"1551697507400928" completion:^(BaaSContentCategory * _Nullable category, NSError * _Nullable error) {

                    }];
                    break;
                    case 4:
                    // 在分类中，查询内容列表
                    [_contentGroup getCategoryListWithQuery:nil completion:^(BaaSContentCategoryListResult * _Nullable listResult, NSError * _Nullable error) {

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
                    [BaaSFileManager uploadWithFilename:@"cover" localPath:filePath categoryName:@"Book" progressBlock:^(NSProgress * _Nullable progress) {

                    } completion:^(BaaSFile * _Nullable file, NSError * _Nullable error) {
                    }];
                    break;
                }
                    case 1:
                    // 获取文件详情
                    [BaaSFileManager get:@"5ca48a56d625d8365d972636" select:nil expand:nil completion:^(BaaSFile * _Nullable file, NSError * _Nullable error) {

                    }];
                    break;
                    case 2:
                {
                    // 获取文件列表
                    [BaaSFileManager findWithQuery:nil completion:^(BaaSFileListResult * _Nullable listResult, NSError * _Nullable error) {

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
                    [BaaSFileManager delete:@[@"fileId"] completion:^(BOOL success, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 5:
                {
                    [BaaSFileManager getCategory:@"5ca489bb8c374f5039a8062b" completion:^(BaaSFileCategory * _Nullable category, NSError * _Nullable error) {

                    }];
                }
                    break;
                    case 6:
                    [BaaSFileManager getCategoryListWithQuery:nil completion:^(BaaSFileCategoryListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];
                    break;
                    case 7:
                    // 获取文件列表
                    [BaaSFileManager findWithCategoryId:@"" query:nil completion:^(BaaSFileListResult * _Nullable listResult, NSError * _Nullable error) {

                    }];


                default:
                    break;
            }
            case 5:
        {
            [BaaS invokeWithName:@"helloWorld" data:@{@"name": @"BaaS"} sync:YES completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

            }];
        }
        default:
            break;
    }
}



@end
