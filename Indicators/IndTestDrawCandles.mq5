//+------------------------------------------------------------------+ 
//|                                                 DRAW_CANDLES.mq5 | 
//|                        Copyright 2011, MetaQuotes Software Corp. | 
//|                                             https://www.mql5.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2011, MetaQuotes Software Corp." 
#property link      "https://www.mql5.com" 
#property version   "1.00" 
  
#property description "An indicator to demonstrate DRAW_CANDLES." 
#property description "It draws candlesticks of a selected symbol in a separate window" 
#property description " " 
#property description "The color and width of candlesticks, as well as the symbol are changed" 
#property description "randomly every N ticks" 
  
#property indicator_separate_window 
#property indicator_buffers 4 
#property indicator_plots   1 
//--- 标图柱形 
#property indicator_label1  "DRAW_CANDLES1" 
#property indicator_type1   DRAW_CANDLES 
#property indicator_color1  clrGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
  
//--- 输入参数 
input int      N=5;              // 改变类型的订单号数量 
input int      bars=500;         // 显示的柱形数量 
input bool     messages=false;   // 在"EA交易"日志显示信息 
//--- 指标缓冲区 
double         Candle1Buffer1[]; 
double         Candle1Buffer2[]; 
double         Candle1Buffer3[]; 
double         Candle1Buffer4[]; 
//--- 交易品种名称 
string symbol; 
//--- 存储颜色的数组0到5的 
color colors[]={clrRed,clrBlue,clrGreen,clrPurple,clrBrown,clrIndianRed}; 
//+------------------------------------------------------------------+ 
//| 自定义指标初始化函数                                                | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- 如果柱形非常小 - 提前完成工作 
   if(bars<50) 
     { 
      Comment("Please specify a larger number of bars! The operation of the indicator has been terminated"); 
      return(INIT_PARAMETERS_INCORRECT); 
     } 
//--- 指标缓冲区映射 
   SetIndexBuffer(0,Candle1Buffer1,INDICATOR_DATA); 
   SetIndexBuffer(1,Candle1Buffer2,INDICATOR_DATA); 
   SetIndexBuffer(2,Candle1Buffer3,INDICATOR_DATA); 
   SetIndexBuffer(3,Candle1Buffer4,INDICATOR_DATA); 
//--- 空值 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0); 
//--- 绘制柱形的交易品种名称 
   symbol=_Symbol; 
//--- 设置交易品种的展示 
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close"); 
   IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_CANDLES("+symbol+")"); 
//--- 
   return(INIT_SUCCEEDED); 
  } 
//+------------------------------------------------------------------+ 
//| 自定义指标迭代函数                                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const datetime &time[], 
                const double &open[], 
                const double &high[], 
                const double &low[], 
                const double &close[], 
                const long &tick_volume[], 
                const long &volume[], 
                const int &spread[]) 
  { 
   static int ticks=INT_MAX-100; 
//--- 计算订单号改变样式，颜色和线型宽度 
   ticks++; 
//--- 如果足够数量的订单号被积累 
   if(ticks>=N) 
     { 
      //--- 选择来自市场报价窗口的新交易品种 
      symbol=GetRandomSymbolName(); 
      //--- 改变格式 
      ChangeLineAppearance(); 
      //--- 选择来自市场报价窗口的新交易品种 
      int tries=0; 
      //--- 试图5 次填充缓冲区plot1的交易品种价格 
      while(!CopyFromSymbolToBuffers(symbol,rates_total,0, 
            Candle1Buffer1,Candle1Buffer2,Candle1Buffer3,Candle1Buffer4) 
            && tries<5) 
        { 
         //--- CopyFromSymbolToBuffers() 函数调用的计数器 
         tries++; 
        } 
      //--- 重置0计数器 
      ticks=0; 
     } 
//--- 返回 prev_calculated值以便下次调用函数 
   return(rates_total); 
  } 
//+------------------------------------------------------------------+ 
//| 填充指定蜡烛图                                                     | 
//+------------------------------------------------------------------+ 
bool CopyFromSymbolToBuffers(string name, 
                             int total, 
                             int plot_index, 
                             double &buff1[], 
                             double &buff2[], 
                             double &buff3[], 
                             double &buff4[] 
                             ) 
  { 
//--- 在rates[] 数组中，我们将复制开盘价，最高价，最低价和收盘价 
   MqlRates rates[]; 
//--- 尝试计数器 
   int attempts=0; 
//--- 已复制多少 
   int copied=0; 
//--- 试图25次获得所需交易品种的时间帧 
   while(attempts<25 && (copied=CopyRates(name,_Period,0,bars,rates))<0) 
     { 
      Sleep(100); 
      attempts++; 
      if(messages) PrintFormat("%s CopyRates(%s) attempts=%d",__FUNCTION__,name,attempts); 
     } 
//--- 如果复制足够数量的柱形失败 
   if(copied!=bars) 
     { 
      //--- 形成信息字符串 
      string comm=StringFormat("For the symbol %s, managed to receive only %d bars of %d requested ones", 
                               name, 
                               copied, 
                               bars 
                               ); 
      //--- 在主图表窗口的注释中显示信息 
      Comment(comm); 
      //--- 显示信息 
      if(messages) Print(comm); 
      return(false); 
     } 
   else 
     { 
      //--- 设置交易品种的展示 
      PlotIndexSetString(plot_index,PLOT_LABEL,name+" Open;"+name+" High;"+name+" Low;"+name+" Close"); 
     } 
//--- 初始化空值缓冲区 
   ArrayInitialize(buff1,0.0); 
   ArrayInitialize(buff2,0.0); 
   ArrayInitialize(buff3,0.0); 
   ArrayInitialize(buff4,0.0); 
//--- 在每个订单号上复制缓冲区价格 
   for(int i=0;i<copied;i++) 
     { 
      //--- 计算缓冲区相应的标引 
      int buffer_index=total-copied+i; 
      //--- 写下缓冲区的价格 
      buff1[buffer_index]=rates[i].open; 
      buff2[buffer_index]=rates[i].high; 
      buff3[buffer_index]=rates[i].low; 
      buff4[buffer_index]=rates[i].close; 
     } 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| 随机返回来自市场报价的交易品种                                       | 
//+------------------------------------------------------------------+ 
string GetRandomSymbolName() 
  { 
//--- 市场报价窗口中显示的交易品种数量 
   int symbols=SymbolsTotal(true); 
//--- 列表中的交易品种位置 - 从0到交易品种的随机号 
   int number=MathRand()%symbols; 
//--- 返回指定位置的交易品种名称 
   return SymbolName(number,true); 
  } 
//+------------------------------------------------------------------+ 
//| 改变柱形的外观                                                     | 
//+------------------------------------------------------------------+ 
void ChangeLineAppearance() 
  { 
//--- 形成柱形属性信息的字符串 
   string comm=""; 
//---改变柱形颜色的模块 
   int number=MathRand(); // 获得随机数 
//--- 除数等于colors[]数组的大小 
   int size=ArraySize(colors); 
//--- 获得选择新颜色作为整数除法余数的标引 
   int color_index=number%size; 
//--- 设置颜色为 PLOT_LINE_COLOR 属性 
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]); 
//--- 写下颜色 
   comm=comm+"\r\n"+(string)colors[color_index]; 
//--- 写下交易品种名称 
   comm="\r\n"+symbol+comm; 
//--- 使用注释在图表上显示信息 
   Comment(comm); 
   }