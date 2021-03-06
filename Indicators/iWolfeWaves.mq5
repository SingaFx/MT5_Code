#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot UpArrow
#property indicator_label1  "UpArrow"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DnArrow
#property indicator_label2  "DnArrow"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDeepPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot UpDot
#property indicator_label3  "UpDot"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot DnDot
#property indicator_label4  "DnDot"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDeepPink
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input parameters

enum ESorce{
   Src_HighLow=0,
   Src_Close=1,
   Src_RSI=2,
   Src_MA=3
};

enum EDirection{
   Dir_NBars=0,
   Dir_CCI=1
};

struct SPeackTrough{
   double   Val;
   int      Dir;
   int      Bar;
};

enum EAlerts{
   Alerts_off=0,
   Alerts_Bar0=1,
   Alerts_Bar1=2
};


input EAlerts              Alerts         =  Alerts_off;
input ESorce               SrcSelect      =  Src_HighLow;
input EDirection           DirSelect      =  Dir_NBars;
input int                  RSIPeriod      =  14;
input ENUM_APPLIED_PRICE   RSIPrice       =  PRICE_CLOSE;
input int                  MAPeriod       =  14;
input int                  MAShift        =  0;
input ENUM_MA_METHOD       MAMethod       =  MODE_SMA;
input ENUM_APPLIED_PRICE   MAPrice        =  PRICE_CLOSE;
input int                  CCIPeriod      =  14;
input ENUM_APPLIED_PRICE   CCIPrice       =  PRICE_TYPICAL;
input int                  ZZPeriod       =  14;
input double               K1             =  0.1;
input double               K2             =  0.1;
input double               K3             =  0.1;
input bool                 DrawWaves      =  true;          
input color                BuyColor       =  clrAqua;
input color                SellColor      =  clrRed;
input int                  WavesWidth     =  2;
input bool                 DrawTarget     =  true;
input int                  TargetWidth    =  1;
input color                BuyTargetColor =  clrRoyalBlue;
input color                SellTargetColor=  clrPaleVioletRed;



int handle=INVALID_HANDLE;
//--- indicator buffers
double         UpArrowBuffer[];
double         DnArrowBuffer[];
double         UpDotBuffer[];
double         DnDotBuffer[];

SPeackTrough PeackTrough[];
int PreCount;
int CurCount;
int PreDir;
int CurDir;
int PreLastBuySig;
int CurLastBuySig;
int PreLastSellSig;
int CurLastSellSig;
datetime LastTime;

bool _DrawWaves;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   handle=iCustom(Symbol(),Period(),"ZigZags\\iUniZigZagSW",SrcSelect,
                                             DirSelect,
                                             RSIPeriod,
                                             RSIPrice,
                                             MAPeriod,
                                             MAShift,
                                             MAMethod,
                                             MAPrice,
                                             CCIPeriod,
                                             CCIPrice,
                                             ZZPeriod);
   
   if(handle==INVALID_HANDLE){
      Alert("Error load indicator");
      return(INIT_FAILED);
   }  
  
   SetIndexBuffer(0,UpArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpDotBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DnDotBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,159);   
   
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-10);  
   
   if(SrcSelect==Src_HighLow || SrcSelect==Src_Close){
      _DrawWaves=DrawWaves;
   }
   else{
      _DrawWaves=false;
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrNONE);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrNONE);      
   }     
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectsDeleteAll(0,MQLInfoString(MQL_PROGRAM_NAME));
   ChartRedraw(0);
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

   int start;
   
   if(prev_calculated==0){
      start=1;      
      CurCount=0;
      PreCount=0;
      CurDir=0;
      PreDir=0;      
      CurLastBuySig=0;
      PreLastBuySig=0;
      CurLastSellSig=0;
      PreLastSellSig=0;
      LastTime=0;
   }
   else{
      start=prev_calculated-1;
   }
   

   for(int i=start;i<rates_total;i++){
   
      if(time[i]>LastTime){
         LastTime=time[i];
         PreCount=CurCount;
         PreDir=CurDir;
         PreLastBuySig=CurLastBuySig;
         PreLastSellSig=CurLastSellSig;         
      }
      else{
         CurCount=PreCount;
         CurDir=PreDir;
         CurLastBuySig=PreLastBuySig;
         CurLastSellSig=PreLastSellSig;         
      }
   
      UpArrowBuffer[i]=EMPTY_VALUE;
      DnArrowBuffer[i]=EMPTY_VALUE;
      
      UpDotBuffer[i]=EMPTY_VALUE;
      DnDotBuffer[i]=EMPTY_VALUE;    
      
      if(_DrawWaves){
         DeleteObjects(time[i]);
      }  
      
      double hval[1];
      double lval[1];
      
      double zz[1];
      
      // new max      
      
      double lhb[2];
      if(CopyBuffer(handle,4,rates_total-i-1,2,lhb)<=0){
         return(0);
      }
      if(lhb[0]!=lhb[1]){
         if(CopyBuffer(handle,0,rates_total-i-1,1,hval)<=0){
            return(0);
         }      
         if(CurDir==1){
            RefreshLast(i,hval[0]);
         }
         else{
            AddNew(i,hval[0],1);
         }
         CheckDn(rates_total,high,time,i);
      }
     
      
      // new min
      
      double llb[2];
      if(CopyBuffer(handle,5,rates_total-i-1,2,llb)<=0){
         return(0);
      }
      if(llb[0]!=llb[1]){
         if(CopyBuffer(handle,1,rates_total-i-1,1,lval)<=0){
            return(0);
         }         
         if(CurDir==-1){
            RefreshLast(i,lval[0]);
         }
         else{
            AddNew(i,lval[0],-1);
          
         }
         CheckUp(rates_total,low,time,i);
      }      
   }
   
   if(_DrawWaves){
      ChartRedraw(0);
   }
   
   CheckAlerts(rates_total,time);

   return(rates_total);
}
//+------------------------------------------------------------------+

void RefreshLast(int i,double v){
   PeackTrough[CurCount-1].Bar=i;
   PeackTrough[CurCount-1].Val=v;
} 

void AddNew(int i,double v,int d){
   if(CurCount>=ArraySize(PeackTrough)){
      ArrayResize(PeackTrough,ArraySize(PeackTrough)+1024);
   }
   PeackTrough[CurCount].Dir=d;
   PeackTrough[CurCount].Val=v;
   PeackTrough[CurCount].Bar=i;
   CurCount++;   
   CurDir=d;
} 

void CheckUp(int rates_total,const double & low[],const datetime & time[],int i){

   if(CurCount<5 || CurDir!=-1){
      return;
   }   
   
   double v1=PeackTrough[CurCount-5].Val;
   double v2=PeackTrough[CurCount-4].Val;
   double v3=PeackTrough[CurCount-3].Val;
   double v4=PeackTrough[CurCount-2].Val;
   double v5=PeackTrough[CurCount-1].Val;
   
   int i1=PeackTrough[CurCount-5].Bar;
   int i2=PeackTrough[CurCount-4].Bar;               
   int i3=PeackTrough[CurCount-3].Bar;
   int i4=PeackTrough[CurCount-2].Bar;
   int i5=PeackTrough[CurCount-1].Bar;
                  
   if(CurLastBuySig!=i4){
      double d1=K1*(v2-v1);
      if(v3<v1-d1){
         if(v4>v1+d1){
            double d2=K2*(v2-v3);
            if(v4<v2-d2){
               double v5l=y3(i1,v1,i3,v3,i);
               if(v5<v5l){
                  double v4x=y3(i1,v1,i3,v3,i4);
                  double v2x=y3(i1,v1,i3,v3,i2);
                  double h4=v4-v4x;
                  double h2=v2-v2x;
                  if(h2-h4>K3*h2){
                     double tb=TwoLinesCrossX(i1,v1,i3,v3,i2,v2,i4,v4);
                     double tv=y3(i1,v1,i4,v4,tb);
                     UpArrowBuffer[i]=low[i];
                     UpDotBuffer[i]=tv;
                     CurLastBuySig=i4;
                     if(_DrawWaves){
                        DrawObjects(BuyColor,BuyTargetColor,v1,v2,v3,v4,v5l,i1,i2,i3,i4,i5,time,i,tb,tv,rates_total);
                     }
                  }
               }
            }
         }
      }
   }
}

void CheckDn(int rates_total,const double & high[],const datetime & time[],int i){

   if(CurCount<5 || CurDir!=1){ 
      return;
   }

   double v1=PeackTrough[CurCount-5].Val;
   double v2=PeackTrough[CurCount-4].Val;
   double v3=PeackTrough[CurCount-3].Val;
   double v4=PeackTrough[CurCount-2].Val;
   double v5=PeackTrough[CurCount-1].Val;
   
   int i1=PeackTrough[CurCount-5].Bar;
   int i2=PeackTrough[CurCount-4].Bar;               
   int i3=PeackTrough[CurCount-3].Bar;
   int i4=PeackTrough[CurCount-2].Bar;
   int i5=PeackTrough[CurCount-1].Bar;
   
   if(CurLastSellSig!=i4){               
      double d1=K1*(v1-v2);
      if(v3>v1+d1){
         if(v4<v1-d1){                   
            double d2=K2*(v3-v2);                   
            if(v4>v2+d2){
               double v5l=y3(i1,v1,i3,v3,i);
               if(v5>v5l){
                  double v4x=y3(i1,v1,i3,v3,i4);
                  double v2x=y3(i1,v1,i3,v3,i2);
                  double h4=v4x-v4;
                  double h2=v2x-v2;
                  if(h2-h4>K3*h2){   
                     double tb=TwoLinesCrossX(i1,v1,i3,v3,i2,v2,i4,v4);
                     double tv=y3(i1,v1,i4,v4,tb);                              
                     DnArrowBuffer[i]=high[i];
                     DnDotBuffer[i]=tv;
                     CurLastSellSig=i4;   
                     if(_DrawWaves){
                        DrawObjects(SellColor,SellTargetColor,v1,v2,v3,v4,v5l,i1,i2,i3,i4,i5,time,i,tb,tv,rates_total);
                     }
                  }
               }
            }
         }
      }
   }
}

void DeleteObjects(datetime time){
   string prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString(time)+"_";
   ObjectDelete(0,prefix+"12");
   ObjectDelete(0,prefix+"23");
   ObjectDelete(0,prefix+"34");
   ObjectDelete(0,prefix+"45");
   ObjectDelete(0,prefix+"13");
   ObjectDelete(0,prefix+"24"); 
   ObjectDelete(0,prefix+"14");    
   ObjectDelete(0,prefix+"67"); 
   ObjectDelete(0,prefix+"7h");    
}

void DrawObjects( color col,
                  color tcol,
                  double v1,
                  double v2,
                  double v3,
                  double v4,
                  double v5,
                  int i1,
                  int i2,
                  int i3,
                  int i4,
                  int i5,
                  const datetime & time[],
                  int i,
                  double target_bar,
                  double target_value,
                  int rates_total){

   string prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString(time[i])+"_";
                   
   fObjTrend(prefix+"12",time[i1],v1,time[i2],v2,col,WavesWidth);
   fObjTrend(prefix+"23",time[i2],v2,time[i3],v3,col,WavesWidth);   
   fObjTrend(prefix+"34",time[i3],v3,time[i4],v4,col,WavesWidth);
   fObjTrend(prefix+"45",time[i4],v4,time[i5],v5,col,WavesWidth);

   if(DrawTarget){   
    
      datetime TargetTime;
      
      int tbc=(int)MathCeil(target_bar);
      
      if(tbc<rates_total){
         TargetTime=time[tbc];
      }
      else{
         TargetTime=time[rates_total-1]+(tbc-rates_total+1)*PeriodSeconds();
      }
      
      double tv13=y3(i1,v1,i3,v3,tbc);   
      double tv24=y3(i2,v2,i4,v4,tbc);  
      double tv14=y3(i1,v1,i4,v4,tbc); 

      fObjTrend(prefix+"13",time[i1],v1,TargetTime,tv13,tcol,TargetWidth);   
      fObjTrend(prefix+"24",time[i2],v2,TargetTime,tv24,tcol,TargetWidth);  
      fObjTrend(prefix+"14",time[i1],v1,TargetTime,tv14,tcol,TargetWidth);
      fObjTrend(prefix+"67",TargetTime,tv24,TargetTime,tv14,tcol,TargetWidth);   
      fObjTrend(prefix+"7h",time[i],target_value,TargetTime,target_value,tcol,TargetWidth);      
   }
}

double TwoLinesCrossX(double x11,double y11,double x12,double y12,double x21,double y21,double x22,double y22){
   double k2=(y22-y21)/(x22-x21);
   double k1=(y12-y11)/(x12-x11);
   return((y11-y21-k1*x11+k2*x21)/(k2-k1));
}

double y3(double x1,double y1,double x2,double y2,double x3){
   return(y1+(x3-x1)*(y2-y1)/(x2-x1));
}

void fObjTrend(   string  aObjName,
                  datetime aTime_1,
                  double   aPrice_1,
                  datetime aTime_2,
                  double   aPrice_2,
                  color    aColor      =  clrRed,  
                  color    aWidth      =  1,                
                  bool     aRay_1      =  false,
                  bool     aRay_2      =  false,
                  string   aText       =  "",
                  int      aWindow     =  0,                  
                  color    aStyle      =  0,
                  int      aChartID    =  0,
                  bool     aBack       =  false,
                  bool     aSelectable =  false,
                  bool     aSelected   =  false,
                  long     aTimeFrames =  OBJ_ALL_PERIODS
               ){
   ObjectCreate(aChartID,aObjName,OBJ_TREND,aWindow,aTime_1,aPrice_1,aTime_2,aPrice_2);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_BACK,aBack);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_COLOR,aColor);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTABLE,aSelectable);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_SELECTED,aSelected);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_TIMEFRAMES,aTimeFrames);
   ObjectSetString(aChartID,aObjName,OBJPROP_TEXT,aText);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_WIDTH,aWidth);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_STYLE,aStyle);
   ObjectSetInteger(aChartID,aObjName,OBJPROP_RAY_LEFT,aRay_1);   
   ObjectSetInteger(aChartID,aObjName,OBJPROP_RAY_RIGHT,aRay_2);
   ObjectMove(aChartID,aObjName,0,aTime_1,aPrice_1);
   ObjectMove(aChartID,aObjName,1,aTime_2,aPrice_2);   
}


void CheckAlerts(int rates_total,const datetime & time[]){
   if(Alerts!=Alerts_off){
      static datetime tm0=0;
      static datetime tm1=0;
      if(tm0==0){
         tm0=time[rates_total-1];
         tm1=time[rates_total-1];
      }
      string mes="";
      if(UpArrowBuffer[rates_total-Alerts]!=EMPTY_VALUE && 
         tm0!=time[rates_total-1]
      ){
         tm0=time[rates_total-1];
         mes=mes+" buy";
      }
      if(DnArrowBuffer[rates_total-Alerts]!=EMPTY_VALUE && 
         tm1!=time[rates_total-1]
      ){
         tm1=time[rates_total-1];
         mes=mes+" sell";
      } 
      if(mes!=""){
         Alert(MQLInfoString(MQL_PROGRAM_NAME)+"("+Symbol()+","+IntegerToString(PeriodSeconds()/60)+"):"+mes);
      }        
   }   
}