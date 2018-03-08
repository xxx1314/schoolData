//
//  ViewController.m
//  schoolSelected
//
//  Created by hello on 2018/3/8.
//  Copyright © 2018年 Hello. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    //学校
    NSDictionary *_schoolDic;
    NSArray *_schoolListArr;
    NSArray *_proListArr;
    NSArray *_schoolArray;
    
    //显示
    UILabel *_label;
    //滚动列表
    UIPickerView *_pickerView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"school_ios" ofType:@"json"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:str];
    _schoolDic = dic;
    NSArray *components = [dic allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
    for (int i=0; i<[sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[dic objectForKey: index] allKeys];
        [provinceTmp addObject: [tmp objectAtIndex:0]];
    }
    //学校城市列表
    _proListArr = provinceTmp;
    //第一个省所有学校
    NSString *firstIndex = [sortedArray objectAtIndex:0];
    NSString *firstProvince = [_proListArr objectAtIndex:0];
    NSDictionary *firstDic = [dic objectForKey:firstIndex];
    _schoolArray = [firstDic objectForKey:firstProvince];
    
    // 选择框
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 216)];
    // 显示选中框
    pickerView.showsSelectionIndicator=YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
    _pickerView = pickerView;
    
    
    //确定
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confire) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
    button.frame = CGRectMake(0, 20, self.view.frame.size.width, 50);
    [self.view addSubview:button];
    
    //显示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-100, self.view.frame.size.width,100)];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor redColor];
    [self.view addSubview:label];
    _label = label;
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _proListArr.count;
    }else {
        return _schoolArray.count;
    }
}


//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [_proListArr objectAtIndex:row];
    }else{
        NSMutableArray *schoolArray = [NSMutableArray array];
        for (NSDictionary *dic in _schoolArray) {
            [schoolArray addObject:dic[@"school"]];
        }
        return [schoolArray objectAtIndex:row];
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        //省对应所有学校
        NSDictionary *selectedDic = [_schoolDic objectForKey:[NSString stringWithFormat:@"%ld",row]];
        _schoolArray = [selectedDic objectForKey:_proListArr[row]];
        [pickerView selectRow: 0 inComponent: 1 animated: YES];
        [pickerView reloadComponent: 1];
        
    }
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = nil;
    
    if (component == 0) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 78, 40)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [_proListArr objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }else {
        NSMutableArray *schoolArray = [NSMutableArray array];
        for (NSDictionary *dic in _schoolArray) {
            [schoolArray addObject:dic[@"school"]];
        }
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140, 40)];
        myView.textAlignment =  NSTextAlignmentCenter;
        myView.text = [schoolArray objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }
    return myView;
}



//点击确定显示
- (void)confire{
    NSInteger proviceIndex = [_pickerView selectedRowInComponent: 0]+1 ;
    
    NSInteger schoolIndex = [_pickerView selectedRowInComponent: 1];
    NSString* schoolStr = [_schoolArray[schoolIndex] objectForKey:@"school"];
    NSInteger schoolID = [[_schoolArray[schoolIndex] objectForKey:@"schoolID"] integerValue];
    NSString *str = [NSString stringWithFormat:@"省代号：%ld\n学校代号:%ld\n学校名字:%@%@",proviceIndex,schoolID,[_proListArr objectAtIndex:proviceIndex-1],schoolStr];
    _label.text = str;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
