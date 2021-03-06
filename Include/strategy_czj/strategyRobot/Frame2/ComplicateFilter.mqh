//+------------------------------------------------------------------+
//|                                             ComplicateFilter.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseFilter.mqh"
#include "ClassifyDoubleMa.mqh"
#include "ClassifyRsi.mqh"
#include "ClassifyOneCandle.mqh"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayInt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CLASSIFY_TYPE
  {
   CLASSIFY_TYPE_DOUBLE_MA,// 双均线特征分类器
   CLASSIFY_TYPE_RSI,// RSI特征分类器
   CLASSIFY_TYPE_CANDLE   // 蜡烛分类器
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CComplicateFilter:public CBaseFilter
  {
protected:
   CArrayObj         classify_arr;  // 分类器数组

   CArrayInt         decimal_arr;   // 计算类别组合时的进制数
   CArrayInt         index_arr;  // 当前对应的分类器数组值
   int               index_filter;  // 分类器组合后的序号
protected:
   void              ResetTotalFilterNum();   // 设置类别数
   void              PrepareDecimalArr(); // 计算类别索引所需的decimal_arr数组 
   void              WriteFilterInforToFile();  // 将过滤器的信息写到文件中  
public:
                     CComplicateFilter(void){};
                    ~CComplicateFilter(void){};
   void              CreateCandleClassify(CandleCombineType c_type=ENUM_CANDLE_TYPE_ONE); // 创建蜡烛分类器
   void              CreateCandleClassify(int num_candle,ENUM_TIMEFRAMES tf);
   void              CreateDoubleMaClassify();  // 创建MA分类器
   void              CreateRsiClassify(); // 创建RSI分类器

   void              InitFilterState();   // 初始化过滤器状态
   void              RefreshTickClassifyState();   // 刷新tick分类器的状态
   void              RefreshBarClassifyState();   // 刷新bar分类器的状态
   ENUM_MAPPING_TYPE GenerateMappingRelation();   // 获取当前状态下的分类对应的mapping类型
   string            GetFilterComment();  // 获取当前的comment
   string            GetFilterComment(int filter_index); // 获取指定复合索引的comment
   string            GetFilterCode(int filter_index);    //  获取指定复合索引对应的分类索引组合
   string            CurrentIndexArrToStr(); // 将当前的分类器编码转换成string
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::ResetTotalFilterNum(void)
  {
   int cc_n;
   if(classify_arr.Total()==0) cc_n=0;
   else
     {
      cc_n=1;
      for(int i=0;i<classify_arr.Total();i++)
        {
         CBaseClassify *cf=classify_arr.At(i);
         cc_n*=cf.GetTotal();
        }
     }
   SetTotalFilterNum(cc_n);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::InitFilterState(void)
  {
   ResetTotalFilterNum(); // 根据分类器列表重新生成过滤器的总数
   PrepareDecimalArr();   // 生成分类器数组对应的进制数组，用于计算类别组合对应的总索引
   RefreshTickClassifyState();
   RefreshBarClassifyState();
   Print("初始化过滤器。。。");
   Print("---过滤类使用的分类特征数:",classify_arr.Total());
   Print("---过滤器产生的类别总数:",total_filter);
   WriteFilterInforToFile();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::PrepareDecimalArr(void)
  {
   decimal_arr.Clear();
   for(int i=0;i<classify_arr.Total();i++)
     {

      if(i==0) decimal_arr.Add(1);
      else
        {
         CBaseClassify *cf=classify_arr.At(i-1);
         decimal_arr.Add(decimal_arr.At(decimal_arr.Total()-1)*cf.GetTotal());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::CreateCandleClassify(CandleCombineType c_type=0)
  {
   switch(c_type)
     {
      case ENUM_CANDLE_TYPE_ONE: CreateCandleClassify(1,PERIOD_H1);break;
      case ENUM_CANDLE_TYPE_TWO: CreateCandleClassify(2,PERIOD_H1);break;
      case ENUM_CANDLE_TYPE_THREE:CreateCandleClassify(3,PERIOD_H1);break;
      case ENUM_CANDLE_TYPE_TWO_D1H4H1:
         CreateCandleClassify(2,PERIOD_D1);
         CreateCandleClassify(2,PERIOD_H4);
         CreateCandleClassify(2,PERIOD_H1);
         break;
      case ENUM_CANDLE_TYPE_THREE_D1H4H1:
         CreateCandleClassify(3,PERIOD_D1);
         CreateCandleClassify(3,PERIOD_H4);
         CreateCandleClassify(3,PERIOD_H1);
         break;
      case ENUM_CANDLE_TYPE_ONE_D1H4H1:
         CreateCandleClassify(1,PERIOD_D1);
         CreateCandleClassify(1,PERIOD_H4);
         CreateCandleClassify(1,PERIOD_H1);
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::CreateCandleClassify(int num_candle,ENUM_TIMEFRAMES tf)
  {
   for(int i=0;i<num_candle;i++)
     {
      CClassifyOneCandle *cf=new CClassifyOneCandle();
      cf.InitOneCandle(symbol,tf,i+1,0);
      classify_arr.Add(cf);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::CreateDoubleMaClassify(void)
  {
   CClassifyDoubleMa *cf=new CClassifyDoubleMa();
   cf.InitDoubleMa(symbol);
   classify_arr.Add(cf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::CreateRsiClassify(void)
  {
   CClassifyRsi *cf=new CClassifyRsi();
   cf.InitRsi(symbol);
   classify_arr.Add(cf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::RefreshTickClassifyState(void)
  {
   for(int i=0;i<classify_arr.Total();i++)
     {
      CBaseClassify *cf=classify_arr.At(i);
      if(cf.GetClasssifyRefreshType()==ENUM_CLASSIFY_REFRESH_TICK) cf.CalClassifyResult();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::RefreshBarClassifyState(void)
  {
   for(int i=0;i<classify_arr.Total();i++)
     {
      CBaseClassify *cf=classify_arr.At(i);
      if(cf.GetClasssifyRefreshType()==ENUM_CLASSIFY_REFRESH_BAR) cf.CalClassifyResult();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MAPPING_TYPE CComplicateFilter::GenerateMappingRelation()
  {
   index_arr.Clear();
   index_filter=0;
   for(int i=0;i<classify_arr.Total();i++)
     {
      CBaseClassify *cf=classify_arr.At(i);
      int k=cf.GetClassifyResult();
      index_arr.Add(k);
      index_filter+=k*decimal_arr.At(i);
     }
   return m_type[index_filter];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CComplicateFilter::GetFilterComment(void)
  {
   string c;
   for(int i=0;i<classify_arr.Total();i++)
     {
      CBaseClassify *cf=classify_arr.At(i);
      c+=cf.GetClassComment()+"-";
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CComplicateFilter::GetFilterCode(int filter_index)
  {
   string c;
   int r=filter_index;
   int total=classify_arr.Total();
   int index_temp[];
   ArrayResize(index_temp,total);
   for(int i=total-1;i>=0;i--)
     {
      CBaseClassify *cf=classify_arr.At(i);
      index_temp[i]=filter_index/decimal_arr.At(i);
      filter_index=filter_index%decimal_arr.At(i);
      c+=IntegerToString(index_temp[i])+"-";
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CComplicateFilter::GetFilterComment(int filter_index)
  {
   string c;
   int r=filter_index;
   int total=classify_arr.Total();
   int index_temp[];
   ArrayResize(index_temp,total);
   for(int i=total-1;i>=0;i--)
     {
      CBaseClassify *cf=classify_arr.At(i);
      index_temp[i]=filter_index/decimal_arr.At(i);
      filter_index=filter_index%decimal_arr.At(i);
      c+=cf.GetClassComment(index_temp[i])+"-";
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CComplicateFilter::CurrentIndexArrToStr(void)
  {
   string c;
   for(int i=0;i<index_arr.Total();i++)
     {
      c+=IntegerToString(index_arr.At(i));
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicateFilter::WriteFilterInforToFile(void)
  {
   Print("Write infor...");
   string file_title;
   for(int i=0;i<classify_arr.Total();i++)
     {
      CBaseClassify *cf=classify_arr.At(i);
      file_title+=cf.GetClassifyName()+"-";
     }
   file_title+=IntegerToString(total_filter)+".csv";
   if(FileIsExist(file_title)) return;
   int file_handle=FileOpen(file_title,FILE_WRITE|FILE_CSV|FILE_COMMON);
   Print("file open...");
   if(file_handle!=INVALID_HANDLE)
     {
      FileWrite(file_handle,"index","comment","code");
      for(int i=0;i<total_filter;i++)
        {
         FileWrite(file_handle,i,GetFilterComment(i),GetFilterCode(i));
        }
      FileClose(file_handle);
      Print("file close...");
     }
   else Print("打开文件失败");
  }
//+------------------------------------------------------------------+
