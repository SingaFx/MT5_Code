//+------------------------------------------------------------------+
//|                                                         wave.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "william"

//--- indicator buffers
double   theprice[];

double   newhigh[];
double   newlow[];
double   william[];

string   nextsymbol;
bool needfresh=true;
int win; 
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

int para1[] = {13,89,377,610,1597,4181,17711};
int para2[] = {8,48,192,384,768,2304,11520};
int para3[] = {5,34,144,233,377,1597,6765};
int para4[] = {3,21,89,144,233,987,4181};
int para[] ;


int OnInit()
  {
  ArrayCopy(para,para4);
  Print("helloadsfdads111");
   switch(Period())
     {
      case PERIOD_M1:win = para[6];break;
      case PERIOD_M5:win = para[5];break;
      case PERIOD_M15:win = para[4];break;
      case PERIOD_M30:win = para[3];break;
      case PERIOD_H1:win = para[2];break;
      case PERIOD_H4:win = para[1];break;
      case PERIOD_D1:win = para[0];break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);

     }

   if(StringCompare(Symbol(),"XAUUSD")==0)
     {
      nextsymbol="USDJPY";
     }
   else if(StringCompare(Symbol(),"USDJPY")==0)
     {
      nextsymbol="XAUUSD";
     }
   else
     {
      Alert("wrong symbol:",Symbol());
      needfresh=false;
      return(INIT_FAILED);
     }

   SetIndexBuffer(0,william,INDICATOR_DATA);
   SetIndexBuffer(1,theprice,INDICATOR_DATA);
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
  	//PositionSelect("XAUUSD");
  	//Print(PositionGetDouble(POSITION_PROFIT));
   if(!needfresh) {Print("sldkfj");return rates_total;}
	
   static int nextpos=0;
   uint timestart;
   if(prev_calculated == 0) 
   {
   	nextpos = 0;//prev_calculated ==0 有三种情况，初次计算，出现错误需要重新计算，人工刷新导致重新计算
   	timestart = GetTickCount();
   }
   int nextbars=Bars(nextsymbol,Period());
   if(nextbars<1)
   {
   	SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED);
   	if(prev_calculated==0)nextpos=0;
   	return prev_calculated;

   //bar太少，有可能是因为在切换周期的时候引起的，只要重新计算指标，就可以了，//一直出现这个又是什么鬼？
      Alert("bar num too low:",nextbars,"prev:",prev_calculated," nextsymbol:",nextsymbol);//
      //needfresh = false;
      nextpos=0;
      return 0;
   }
   int start=MathMax(0,prev_calculated-1); //第一根不计算
   MqlRates nextrates[];
   int datalen=CopyRates(nextsymbol,Period(),0,nextbars-nextpos+1,nextrates);
   if(datalen<0)
     {
      Alert("rates too less:",datalen," ",nextbars," ",nextpos);
      //needfresh = false;
      nextpos=0;
      return 0;
     }
   int j=0,findj = 0;
   for(int i=start;i<rates_total;i++)
     {
     	
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
         	
         	/*
         	if(rates_total-i<3)
         	{/*
         		Print("sldkf");
         		Print(j);
         		Print(datalen);
         		Print(nextbars);
         		Print(nextpos);
         		Print("sldkf end");
         	//	}
         	/*
         	Print("sldkfjdf");
         		Print(i);
         		Print(time[i]);
         		if(j<datalen)
         			Print(nextrates[j].time);
         		else
         			Print("lasttime:",nextrates[j-1].time);
         	}//*/

         }
         
         
        }
      else
      {
      //剩下就是time1 = time2的情况了
      	theprice[i]=//(close[i] + nextrates[j].close*10);//);// * 10;
                  sqrt(close[i]*nextrates[j].close);
         //Print(theprice[i]);
         //Print("close[i]:",close[i]);
         //Print("nextrates[j].close:",nextrates[j].close);
        	//*
        	findj = j;
        	/*Print("normal begin");
        	Print(nextbars);
        	Print(nextpos);
        	Print(j);
        	Print(datalen);
        	Print(i);
        	Print(rates_total);
        	Print("normal end");//*/
         j++;
      }      
      if(theprice[i] < 10)
      {
      	if(i==0)
            theprice[i]=0;
         else
         {
            theprice[i]=theprice[i-1];
            //Print("kkkkkk");
         }
      }
      //Print(theprice[i],"  ",i);
      
      //计算其william指标,只使用收盘价来计算
      if(i>=win-1)
      {
      	int themax_ind = ArrayMaximum(theprice,i-win+1,win);
      	int themin_ind = ArrayMinimum(theprice,i-win+1,win);
      	if(themax_ind==themin_ind)
      	{
      		//if(i ==0)
      		////	william[i] = 0;
      		//else
      			william[i] = william[i-1];
      			
      	}
      	else
      	{
      		
      		william[i] = (theprice[i]-theprice[themin_ind])/(theprice[themax_ind]-theprice[themin_ind]);
      		//Print(william[i]);
      		//Print(themax_ind);
      		//Print(themin_ind);
      		//Print(theprice[i]);
      		//Print(theprice[themin_ind]);
      		//Print(theprice[themax_ind]);
      	}
      }
      else
      {
      	william[i] = 0;
      	//Print("llllll");
      }
      
      
      
      //*/
      
     }
   /*Print("result begin11");
        	Print(j);
        	Print(datalen);
        	
        	Print("result end11");
   if(j<=datalen){nextpos+=j-1;Print("bbbbb");}//nextbars;
   Print("result begin");
        	Print(nextbars);
        	Print(nextpos);
        	
        	Print("result end");*/
   nextpos=nextpos+findj;     	

   if(prev_calculated==0)
     {

      //将结果写入文件

     }
	if(prev_calculated ==0)
	{
		Print("Time: ",GetTickCount()-timestart);
	}
//---

//--- return value of prev_calculated for next call
   return(rates_total);
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
