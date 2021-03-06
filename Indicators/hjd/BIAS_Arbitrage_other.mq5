//+------------------------------------------------------------------+
//|                                                         wave.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Math/Alglib/statistics.mqh>
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   5
//*
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_label1  "BAIS"
//*
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_label2  "UP"//*/
//*
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_label3  "DOWN"

#property indicator_type4   DRAW_NONE
#property indicator_color4  clrGreen
#property indicator_label4  "slope"

#property indicator_type5   DRAW_NONE
#property indicator_color5  clrGreen
#property indicator_label5  "difprice"
/*
#property indicator_type6   DRAW_NONE
#property indicator_color6  clrGreen
#property indicator_label6  "slope2"

#property indicator_type7   DRAW_NONE
#property indicator_color7  clrGreen
#property indicator_label7  "slope3"//*/
//--- indicator buffers

double   theprice[];

double   thema[];
double   theema[];
double   thebais[];
double   up[];
double   down[];
double   slope[];

string   nextsymbol;
bool needfresh=true;
int win; 
int win2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//斐波那契数列:1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,
//1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//13天 = 78*4小时 = 312 小时 = 624 * 30min = 1248 * 15min = 3744 * 5min = 6240 * 3min =  9360 * 2min = 18720 min
//13     89         377        610           1597           4181          6765           10946         17711

//DAY			13			13			8			8			5		5			3		3
//4HOURS		78			89			48			55			30		34			18		21
//HOUR		312		377		192		233		120	144		72		89
//30MINS		624		610		384		377		240	233		144	144
//15MIN		1248		1597		768		610		480	377		288	233
//5Min		3744		4181		2304		2584		1440	1597		964	987
//1Min		18720		17711		11520		10946		7200	6765		4320	4181
//
enum CORRELATION{COR_POSITIVE,COR_NEGATIVE,COR_DIFF}; //正相关，价差使用对数差；负相关，价差使用对数和；价格差，价格直接求差
enum BAIS_MODE{BM_CLOSE,BM_EMA};
input double thewin = 0.5;//周期的天数
input double thewin2 = 3; //统计长周期 
input double confidence_interval = 0.95 ;  //日交易平率， 
input string symbol1="XAUUSD" ; //品种1
input string symbol2="USDJPY";  //品种2
input double hourinday1=23; //品种1的一天交易时长
input double hourinday2=24; //品种2的一天交易时长
input CORRELATION m_correlation = COR_NEGATIVE;
input BAIS_MODE m_baismode = BM_CLOSE;
input double minthre = 0.0;
input double offset = 12 ;  //为确保价差>0,并且尽可能消除品种对的差异性

input double max_value1 = FLT_MAX;
input double min_value1 = 0;
input double max_value2 = FLT_MAX;
input double min_value2 = 0;

//double threshold;

//首先根据thewin来确定乖离线的周期，用固定时长来做，是为了确保数据周期的改变不会对策略产生明显的影响
//在此通过thewin来确定统计周期，并且画出上下轨出来。

//string symbol1 ="USDJPY";
//string symbol2 ="GBPUSD";
int OnInit()
  {
  //ArrayCopy(para,para4);
  Print("helloadsfdads111");
   

   if(StringCompare(Symbol(),symbol1)==0)
   {
      switch(Period())
      {
      case PERIOD_M1:win = int(thewin*hourinday1*60); break;
      case PERIOD_M5:win = int(thewin*hourinday1*12);break;
      case PERIOD_M15:win = int(thewin*hourinday1*4);break;
      case PERIOD_M30:win = int(thewin*hourinday1*2);break;
      case PERIOD_H1:win = int(thewin*hourinday1);break;
      case PERIOD_H4:win = int(thewin*6);break;
      case PERIOD_D1:win = int(thewin);break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);

      }
      nextsymbol=symbol2;
   }
   else if(StringCompare(Symbol(),symbol2)==0)
   {
      switch(Period())
      {
      case PERIOD_M1:win = int(thewin*hourinday2*60); break;
      case PERIOD_M5:win = int(thewin*hourinday2*12);break;
      case PERIOD_M15:win = int(thewin*hourinday2*4);break;
      case PERIOD_M30:win = int(thewin*hourinday2*2);;break;
      case PERIOD_H1:win = int(thewin*hourinday2);break;
      case PERIOD_H4:win = int(thewin*6);break;
      case PERIOD_D1:win = int(thewin);break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);

      }
      nextsymbol=symbol1;
   }
   else
     {
      Print("wrong symbol1:",Symbol());
      needfresh=false;
      return(INIT_FAILED);
     }
   win2 = win * thewin2 / thewin;
   //threshold = fre/barinoneday;
   
   

   Print("thewin:",win,";thewin2:",win2);
   SetIndexBuffer(0,thebais,INDICATOR_DATA);
   SetIndexBuffer(1,up,INDICATOR_DATA);   
   SetIndexBuffer(2,down,INDICATOR_DATA);
   SetIndexBuffer(3,slope,INDICATOR_DATA);
   SetIndexBuffer(4,theprice,INDICATOR_DATA);
   SetIndexBuffer(5,thema,INDICATOR_DATA);   
   SetIndexBuffer(6,theema,INDICATOR_DATA);
   
   //SetIndexBuffer(2,newhigh,INDICATOR_CALCULATIONS);
   //SetIndexBuffer(3,newlow,INDICATOR_CALCULATIONS);

//--- indicator buffers mapping
	bool synchronized=false;
      //--- 循环计数器
   int attempts=0;
      // 进行5次尝试等候同步进行
   while(attempts<5)
   {
      if(SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED))
      {
            //--- 同步化完成，退出
         synchronized=true;
         break;
      }
         //--- 增加计数器
      attempts++;
         //--- 等候10毫秒直至嵌套反复
      Sleep(10);
   }
      //--- 同步化后退出循环
   if(synchronized)
   {
      
      Print("The first date in the terminal history for the symbol-period at the moment = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_FIRSTDATE));
      Print("The first date in the history for the symbol on the server = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_SERVER_FIRSTDATE));
   }
      //--- 不发生数据同步
   else
   {
      Print("Failed to get number of bars for ",nextsymbol);
      //如果这这里同步不了的话，那么就继续让程序跑，获不到bar的情况下，他会再做一次同步
      //return(INIT_FAILED);
   }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
	
	static double last_normal_value1,last_normal_value2;  // 用于存放上一个有效的值
   static double max_latest = -DBL_MAX;
   static double min_latest = DBL_MAX;
   static double sum_value=DBL_MAX;
   static bool isbusy = false;
   if(prev_calculated>rates_total)
   return 0;
   if(rates_total>0)
   {
   	thebais[rates_total -1] = DBL_MAX;// 将最后一个值赋为异常值
   }
   if(prev_calculated != rates_total) // 有多跟bar要算，最后的bar的轨道半径先置最大，防止出事
   {
   	up[rates_total - 1] = DBL_MAX;
   	down[rates_total - 1] = -DBL_MAX;
   }
   if(rates_total < win + win2 || rates_total < prev_calculated) //数据不够
   	return 0;
   
   if(isbusy)
   {
   	Print("is busy");
    	return prev_calculated;
   } 	
   isbusy = true;
   if(!needfresh) 
   {//Print("sldkfj");
   	isbusy = false;
   	return rates_total;   	
   }
   static int nextpos=0;
   uint timestart;
   if(prev_calculated == 0) 
   {
   	//Print("rates_total:",rates_total);
      sum_value = DBL_MAX;
   	timestart = GetTickCount();
   	//ArrayInitialize(thebais,DBL_MAX);  //thebias指标异常的状态，在策略中，当发现thebias过大，就可以认为指标有问题，不能作为开平仓或者指标记录的依据
   	//ArrayInitialize(up,0);   	
   	//ArrayInitialize(down,-0);
   	//ArrayInitialize(theprice,0);
   }   
   
   int nextbars=Bars(nextsymbol,Period());
   if(nextbars<1)
   {
   	SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED);
   	isbusy = false;
   	return prev_calculated;
   }
   int start=MathMax(0,prev_calculated-1); //开始
   start = MathMax(start,rates_total - win - win2-50000);
   MqlRates nextrates[];
   int datalen=CopyRates(nextsymbol,Period(),time[start],time[rates_total-1],nextrates);
   if(datalen<=0)
     {
   	isbusy = false;
      return prev_calculated;
     }
   int j=0,findj = 0,i;
   for(i = start; i < rates_total; i++)
   {
     	if(i)
     		theprice[i]=theprice[i-1]; 
      for(;j<datalen;j++)
        {
         //有三种情况，time1 > time2,time1<time2,time1=time2;
         if(time[i]>nextrates[j].time)continue;   // time1 > time2，继续寻找下一个time2
                                                  //if(time[i] < nextrates[j].time) break;     // time1 < time2,继续寻找下一个time1,跳出这个循环后，continue下一个循环
         break;
         //time1 < time2 和time1 = time2 都是直接跳出
        }
      if(j>=datalen || time[i]<nextrates[j].time)
        {//找到最后都没有找到与当前bar对应的bar,也就是当前bar的时间要比对应品种的最新时间还要新，说明这个bar时间及之后对应品种都没有交易，直接跟新所有的
         //j++;
         if(i==0)
            theprice[i]=0;
         else
         {
         	theprice[i]=theprice[i-1];   
         }
        }
      else
      {
      //剩下就是time1 = time2的情况了
      //首先判断两个价格是否都是正常的
      	if(close[i] <= min_value1 || close[i] >= max_value1 || nextrates[j].close <= min_value2 || nextrates[j].close >= max_value2) // 异常的bar线，有问题
      	{
      		PrintFormat("theprice is wrong!!!! close1 = %f, close2 = %f",close[i],nextrates[j].close);
   			isbusy = false;
      		thebais[i] = DBL_MAX;
      		return i + 1;
      	}
      	
      	else if((i && (close[i-1]/close[i] > 5 || close[i-1]/close[i] < 0.2 ))  || 
      	        (j && (nextrates[j-1].close/nextrates[j].close > 5 || nextrates[j-1].close/nextrates[j].close <0.2 )))
      	{
      		isbusy = false;
      		thebais[i] = DBL_MAX;
      		return i + 1;
      	}
      
         switch(m_correlation)
         {
            case COR_POSITIVE: theprice[i]=log(close[i]/nextrates[j].close)+offset;break;
            case COR_NEGATIVE: theprice[i]=log(close[i]*nextrates[j].close)+offset;break;
            case COR_DIFF   : theprice[i]=close[i]-nextrates[j].close+offset;break;
         }
        	findj = j;
         j++;
      }    
       
      
      if(i>0)
         theema[i] = 2.0 / (win+1.0)*(theprice[i] -theema[i-1]) + theema[i-1];  // EMA = a *(price + lastEMA) - lastEMA; a = 2/(win+1)
      else
         theema[i] = theprice[i];
      if(i>=win-1&& i>=rates_total-50000-win2)
      {
         if(sum_value > FLT_MAX)
         {
            sum_value = 0.0f;
            for(int k = i-win+1;k<i;k++)//win -1 ge  //初始化总价
            {
               sum_value += theprice[k];
            }
         }
         if(start == rates_total-1) //在只有一根bar的时候，不用每次都计算全数据,可以有效提升效率
         {
            thema[i] = (sum_value + theprice[i]) / win ;
         
         }
         else
         {
            thema[i] = (sum_value + theprice[i]) / win ;
            if(i<rates_total-1)
               sum_value += theprice[i] - theprice[i-win+1];//加上当前的price，减去最旧的一个price，形成新的win-1的总数，给，i+1使用
      	}
      	if(MathAbs(thema[i])<0.1)
      	   thebais[i] =0;
      	else
      	   switch(m_baismode)
            {
               case BM_CLOSE: thebais[i] = (theprice[i]/thema[i]-1.0)*1000;break;//
               case BM_EMA  : thebais[i] = (theema[i]/thema[i]-1.0)*1000;break;
            }
      }
      else
      {
         sum_value=DBL_MAX;
      	thema[i] = 0;
      	
      }//*/
      
      if(i > win2 + win)
      {
         if(start != rates_total-1 && i >= rates_total - 50000)
         {
            double tempval =  FindMaxAbs_N6(i-1,win2,thebais,confidence_interval,minthre); //计算轨道半径
            up[i] = tempval;
            down[i] = -tempval;
         }
      }
      
      slope[i] =i>0? thema[i] -  thema[i-1]:0;
	}
	if(up[rates_total-1] < minthre / 2 || down[rates_total-1] > minthre /2 || theprice[i-win+1] < 0.001)
   {
   	isbusy = false;
		return 0; // 重新计算
	}
      
      
   if(prev_calculated==0)
     {

      //将结果写入文件

     }
	if(prev_calculated ==0)
	{
		Print("Time: ",GetTickCount()-timestart," last bias=",thebais[rates_total-2],"  lastup:",up[rates_total-2],"  lasttime:",time[rates_total-2]);
		Print("current bias=",thebais[rates_total-1],"  current up:",up[rates_total-1],"  current time:",time[rates_total-1]);
	}
	if(up[rates_total-1] > FLT_MAX)
	{
		//指标异常
		PrintFormat("异常的值，rates=%i，start=%i，i=%i，j=%i，time1=%s，time2=%s，bias=%f",rates_total,start,i,j,TimeToString(time[i-1],TIME_DATE|TIME_SECONDS),TimeToString(nextrates[j-1].time,TIME_DATE|TIME_SECONDS),thebais[rates_total-1]);
	}
	//
	if(rates_total != prev_calculated) //就是非当前bar内的更新，这个时候为了保险起见，先将bias值置为异常，等待他的更新
		thebais[rates_total - 1] = DBL_MAX;
//---

//--- return value of prev_calculated for next call
   isbusy = false;
   return(rates_total);
}

double SamplePercentile(double &cx[],const int first,const int last,const int n)//返回数值cx中的第n个大的数
{
//	first,last 为其下标
	if (first > last) 
		return DBL_MAX; //不应该在这个地方里面返回
	if	(first == last) 
		return cx[first];
	int i = first;
   int j = last;
   double key = cx[i];/*用字表的第一个记录作为枢轴*/
 
   while(i < j)
   {
   	
   	while(i < j && cx[j] >= key)
      {
      	--j;
      }
      cx[i] = cx[j];/*将比第一个小的移到低端*/
 
      while(i < j && cx[i] <= key)
      {
      	++i;
      } 
      cx[j] = cx[i];    
/*将比第一个大的移到高端*/
	}
  	cx[i] = key;/*枢轴记录到位*/
  	if(i == n)
  		return cx[i];
  	if(i > n)
  		return SamplePercentile(cx,first,i-1,n);
  	else
  		return SamplePercentile(cx,i+1,last,n); 	
}

double FindMaxAbs_N7(int position,int windows,double &array[],double the_interval,double min_val = 0.0f)
{// 使用快速排序的方法来找到第N个大小	
	if(position < windows)
      return DBL_MAX;
   int arraysize = (windows * (1-the_interval));//至少要有一个数
   if(arraysize > windows)
   	return DBL_MAX;
   double theprice[];
   ArrayResize(theprice,windows);
   int j = 0;
   for(int i = position-windows+1;i<=position;i++)
   {
   	theprice[j++] = array[i] >= 0 ? array[i]:0-array[i];
   }
   for(int i = 0;i<arraysize;i++)
   {
   	int ind = ArrayMaximum(theprice,0,windows-i);
   	theprice[ind] = theprice[windows - 1 - i];
   }
   int ind = ArrayMaximum(theprice,0,windows-arraysize); 
   return theprice[ind];
}


double FindMaxAbs_N6(int position,int windows,double &array[],double the_interval,double min_val = 0.0f)
{// 使用快速排序的方法来找到第N个大小	
	if(position < windows)
      return DBL_MAX;
   int arraysize = windows * (1.0-the_interval);//至少要有一个数 ,查找在windows里面的第arraysize个
   if(arraysize > windows)
   	return DBL_MAX;
   double theprice[],tempprice[];
   ArrayResize(tempprice,windows);//最多windows个符合条件
   int count = 0;
   for(int i = position-windows+1;i<=position;i++)
   {
   	double theval = array[i] >= 0 ? array[i]:0-array[i];
   	if(theval>min_val)
   		tempprice[count++] = theval;
   }
   if(count < arraysize)
   	return min_val;
   ArrayResize(theprice,count);
   ArrayCopy(theprice,tempprice,0,0,count);
   double res = SamplePercentile(theprice,0,count-1,count - arraysize);
   return res;
}

double FindMaxAbs_N5(int position,int windows,double &array[],double the_interval,double min_val = 0.0f)
{// 使用快速排序的方法来找到第N个大小	
	if(position < windows)
      return DBL_MAX;
   int arraysize = (windows * (the_interval));//至少要有一个数
   if(arraysize > windows)
   	return DBL_MAX;
   double theprice[];
   ArrayResize(theprice,windows);
   int j = 0;
   for(int i = position-windows+1;i<=position;i++)
   {
   	theprice[j++] = array[i] >= 0 ? array[i]:0-array[i];
   }
   double res = SamplePercentile(theprice,0,windows-1,arraysize);
   return res;
}

double FindMaxAbs_N4(int position,int windows,double &array[],double the_interval,double min_val = 0.0f)
{	
	if(position < windows)
      return DBL_MAX;
   double theprice[];
   ArrayResize(theprice,windows);
   int j = 0;
   for(int i = position-windows+1;i<=position;i++)
   {
   	theprice[j++] = array[i] >= 0 ? array[i]:0-array[i];
   }
   double res = 0.0f;
   CBaseStat::SamplePercentile(theprice,windows,the_interval,res);
   return MathMax(res,min_val);
}

double FindMaxAbs_N3(int position,int windows,double &array[],double the_interval,double min_val = 0.0f)
{
	
	if(position < windows)
      return DBL_MAX;
   int arraysize = MathMax(windows * (1.0-the_interval),1);//至少要有一个数
   if(arraysize > windows)
   	return DBL_MAX;
   double theprice[],tempprice[];
   ArrayResize(tempprice,windows);//最多windows个符合条件
   int count = 0;
   for(int i = position-windows+1;i<=position;i++)
   {
   	double theval = array[i] >= 0 ? array[i]:0-array[i];
   	if(theval>min_val)
   		tempprice[count++] = theval;
   }
   if(count < arraysize)
   	return min_val;
   ArrayResize(theprice,count);
   ArrayCopy(theprice,tempprice,0,0,count);
   ArraySort(theprice);
   return theprice[count - arraysize];
   
}

double FindMaxAbs_N(int position,int windows,double &array[],double the_interval)
{
   if(position < windows)
      return DBL_MAX;
   double themax[];
   int arraysize = MathMax(windows * (1.0-the_interval),1);//至少要有一个数
   //Print(windows);
   //Print(array[position-windows]);
   ArrayResize(themax,arraysize);
   //Print("windows:",windows,";the_thre:",the_thre,";arraysize:",arraysize);
   //Print("arraysize:",arraysize);
   ArrayInitialize(themax,-DBL_MAX);
   
   /*if(position > 2*windows)
   {
      int zzz;
      zzz =1;
      Print(zzz);
   }*/
   for(int i = position-windows+1;i<=position;i++)
   {
      int j ;
      for(j = 0;j<arraysize;j++)
      {
         if(MathAbs(array[i]) < themax[j]) break;
      }
      if(j>0) //找到他能插入的位置
      {
         for(int k = 1;k<j;k++)
         {
            themax[k-1] = themax[k];
         }
         themax[j-1] = MathAbs(array[i]);
      }
   }
   //Print(themax[0],"  ",arraysize);
   double res = themax[0];
   ArrayFree(themax);
   return res;
  }

double FindMaxAbs_N1(int position,int windows,double &array[],double the_interval,double min_val=0.0f)
{
//增加了一个min_val，这样子就能有效过滤掉一定的数据，减少数值插入移动的次数，提升效率
	min_val = MathMax(min_val,0);
   if(position < windows)
      return DBL_MAX;
   double themax[];
   int arraysize = MathMax(windows * (1.0-the_interval),1);//至少要有一个数
   //Print(windows);
   //Print(array[position-windows]);
   ArrayResize(themax,arraysize);
   //Print("windows:",windows,";the_thre:",the_thre,";arraysize:",arraysize);
   //Print("arraysize:",arraysize);
   ArrayInitialize(themax,min_val);
   
   /*if(position > 2*windows)
   {
      int zzz;
      zzz =1;
      Print(zzz);
   }*/
   int arraycount = 0; //当前插入的数
   double arraymin = min_val;
   for(int i = position-windows+1;i<=position;i++)
   {
   	double curval = MathAbs(array[i]);
   	if(curval <  arraymin) continue;
      
      if(arraycount == 0)
      {//首先放进一个数
      	themax[0] = curval;
      	arraycount ++;
      	
      }
      else  
      {
      	//有一个以上的数据了，那就要找插入点
      	int j ;
      	for(j = 0;j<arraycount;j++)
      	{
      		if(curval > themax[j])break;
      	}
      	if(j == arraycount ) //找不到插入点
      	{
      		if(arraycount < arraysize)
      		{
      			//还能放数据进去，放到最后
      			themax[arraycount++] = curval;
      		}
      		//否则丢弃
      	}
      	else // 找到插入点
      	{
      		if(arraycount < arraysize)
      			arraycount ++ ;
      		for(int k = arraycount-1;k>j;k--)
      		{
      			themax[k] = themax[k-1];
      		}
      		themax[j] = curval;
      	}
      	if(arraycount == arraysize)
      	{
      		min_val = MathMax(min_val,themax[arraycount-1]);
      	}
      
      }
   }
   //Print(themax[0],"  ",arraysize);
   ArrayFree(themax);
   return min_val;
  }
  
double FindMaxAbs_N2(double &array[],double the_interval)
{
	int windows = ArraySize(array);
	if(windows == 0) return DBL_MAX;
   double themax[];
   int arraysize = MathMax(windows * (1.0-the_interval),1);//至少要有一个数
   //Print(windows);
   //Print(array[position-windows]);
   ArrayResize(themax,arraysize);
   //Print("windows:",windows,";the_thre:",the_thre,";arraysize:",arraysize);
   //Print("arraysize:",arraysize);
   ArrayInitialize(themax,-DBL_MAX);
   
   for(int i = 0;i<windows;i++)
   {
      int j ;
      for(j = 0;j<arraysize;j++)
      {
         if(MathAbs(array[i]) < themax[j]) break;
      }
      if(j>0) //找到他能插入的位置
      {
         for(int k = 1;k<j;k++)
         {
            themax[k-1] = themax[k];
         }
         themax[j-1] = MathAbs(array[i]);
      }
   }
   //Print(themax[0],"  ",arraysize);
   double res = themax[0];
   ArrayFree(themax);
   return res;
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
