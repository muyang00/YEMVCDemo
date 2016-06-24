//
//  SeeBallViewController.m
//  MVVMPENews
//
//  Created by Apple on 16/6/21.
//  Copyright © 2016年 杨永恩. All rights reserved.
//

#import "SeeBallViewController.h"
//#import "SeeBallViewModel.h"
#import "SeeBallModel.h"
#import "SeeBallCell.h"



@interface SeeBallViewController ()<NetWorkingHelperDelegate, MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) SeeBallViewModel *viewModel;
@property (nonatomic, strong) SeeBallModel *model;



@property (nonatomic, retain) NSMutableArray *allDataMutableArray;
@property (nonatomic, retain) NSMutableArray *dataSourceMutableArray;
@property (nonatomic, strong) MBProgressHUD *progressHUD;


@end

@implementation SeeBallViewController

- (NSMutableArray *)allDataMutableArray{
    if (!_allDataMutableArray) {
        _allDataMutableArray = [NSMutableArray array];
    }
    return _allDataMutableArray;
}
- (NSMutableArray *)dataSourceMutableArray{
    if (!_dataSourceMutableArray) {
        _dataSourceMutableArray = [NSMutableArray array];
    }
    return _dataSourceMutableArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [self setupTableViewAndHUD];
    
}

- (void)setupTableViewAndHUD{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    [self.tableView registerClass:[SeeBallCell class] forCellReuseIdentifier:@"cell"];
//    self.tableView.rowHeight = 140;
    self.tableView.estimatedRowHeight = 140;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.separatorColor = [UIColor orangeColor];
    [self.view addSubview:self.tableView];
    
    [self configDataFromServer];
    
    
    
#pragma mark - 加载过程提示
    self.progressHUD = [[MBProgressHUD alloc]initWithFrame:self.view.frame];
    [self.progressHUD show:YES];
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"Loading...";
    
#pragma mark - 无网络情况下添加观察者接受通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(displayNotificationAction:) name:@"display" object:nil];

}



#pragma mark - 通知的回调方法
- (void)displayNotificationAction:(NSNotification *)notification{
    
    [self.progressHUD hide:YES];
    self.progressHUD = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:(NSString *)notification.object
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
#pragma mark - NetWorkingHelper解析数据
- (void)configDataFromServer{
    NetWorkingHelper *helper = [[NetWorkingHelper alloc]init];
    helper.delegate = self;
    [helper getRequesMethodWithUrlString:kSeeBallURL parameter:nil];
    
}
//回调方法
- (void)passValueWithDic:(NSDictionary *)valueDic{
    

    for (NSDictionary *dic in valueDic[@"result"][@"data"][@"full"]) {
        
        SeeBallModel *model = [[SeeBallModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataSourceMutableArray addObject:model];
    }
    for (NSDictionary *dic in valueDic[@"result"][@"data"][@"cur"]) {
        
        SeeBallModel *model = [[SeeBallModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataSourceMutableArray addObject:model];
    }
    for (NSDictionary *dic in valueDic[@"result"][@"data"][@"pre"]) {
        
        SeeBallModel *model = [[SeeBallModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataSourceMutableArray addObject:model];
    }
    [self.allDataMutableArray addObjectsFromArray:self.dataSourceMutableArray];
    [self performSelectorOnMainThread:@selector(reloading) withObject:nil waitUntilDone:YES];
}
- (void)reloading{
    if (self.progressHUD) {
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return self.allDataMutableArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     SeeBallCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    SeeBallModel *model = self.allDataMutableArray[indexPath.row];
    
    [Cell setValueWithModel:model];
    
    return Cell;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
