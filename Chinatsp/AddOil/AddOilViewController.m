//
//  [leftBtn setFrame:CGRectMake(4, 4, 60, 38)]; AddOilViewController.m
//  Chinatsp
//
//  Created by yuante on 13-8-28.
//  Copyright (c) 2013年 yuante.Yuan Wen. All rights reserved.
//

#import "AddOilViewController.h"
#import "AddOilCell.h"
#import "NetService.h"
#import "UIHelper.h"
#import "GasStation.h"

@interface AddOilViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataList;
    UIActivityIndicatorView *progressdialog;
}
@end

@implementation AddOilViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    _tableView = nil;
    
    [progressdialog release];
    progressdialog = nil;
    
    [_dataList release];
    _dataList = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *leftBarBtn = [UIBarButtonItem buttonWithTitle:@"首页" imageName:@"btn_back_home" target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    [self.navigationItem setCustomTitle:@"加油查询"];

    _dataList = [[NSMutableArray alloc] init];
    
    [self loadBG];
//    [self loadHeaderView];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [MyUtil viewHeight] - 44) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;

    [self getDataInThread];
}

- (void)loadHeaderView
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
    
    UIImageView *navi = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
    navi.image = [UIImage imageNamed:@"addoil"];
    [self.view addSubview:navi];
    [navi release];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(4, 4, 60, 38)];
    [leftBtn setImage:[UIImage imageNamed:@"btn_back_home"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:leftBtn];
    
    [self.view addSubview:header];
    
    [header release];
}

- (void)loadBG
{
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [MyUtil viewHeight])];
    bg.image = [UIImage imageNamed:@"bg_subviews"];
    [self.view addSubview:bg];
    [bg release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdenty = @"AddOilCell";
    AddOilCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenty];
    
    if (!cell) {
        cell = [AddOilCell addOilCell];
        
    }
    
    if ([_dataList count] > indexPath.row)
    {
        GasStation *gs = [_dataList objectAtIndex:indexPath.row];
        cell.nameLabel.text = gs.title;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10;
//}

- (void)back
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//获取加油数据
-(void)getDataInThread
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSData *data=[[NetService singleHttpService] getCollectListWithType:2];
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          [self getResult:data];
                                      });
                   }) ;
}

-(void)getResult:(NSData *)data
{
    [self closeProgressDialog];
    if(data)
    {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        dataStr = [dataStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSDictionary *nd=[dataStr objectFromJSONString];
        //        NSLog(@"%@",dataStr);
        if([@"OK" isEqualToString:[nd objectForKey:@"resp_status"]])
        {
            if([@"" isEqualToString:[nd objectForKey:@"resp_data"]])
            {
                [UIHelper showAlertview:@"目前没有收藏纪录哦"];
            }
            else
            {
                NSDictionary *respNd=[nd objectForKey:@"resp_data"];
                NSArray *valuearray=respNd.allValues;
                for (NSDictionary *dic in valuearray)
                {
                    GasStation *gs = [[GasStation alloc] init];
                    [gs fillFromDictionary:dic];
                    
                    [_dataList addObject:gs];
                    [gs release];
                }
                if ([_dataList count] > 0)
                {
                    [_tableView reloadData];
                }
            }
        }
        else
        {
            [UIHelper showAlertview:@"获取数据失败,请稍后在试"];
        }
    }
    else
    {
        [UIHelper showAlertview:@"网络异常"];
    }
}

-(void)closeProgressDialog
{
    if (progressdialog) {
        [progressdialog stopAnimating];
        [progressdialog.superview removeFromSuperview];
        progressdialog = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
