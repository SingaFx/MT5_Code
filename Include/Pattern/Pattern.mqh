//+------------------------------------------------------------------+
//|                                                      Pattern.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#include "Enums.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPattern
  {
private:
   //--- Weights
   double            m_k1;
   double            m_k2;
   double            m_k3;
   //--- Threshold trend value in points
   int               m_threshold_value;
   //--- Long candlestick setup coefficient
   double            m_long_coef;
   //--- Short candlestick setup coefficient
   double            m_short_coef;
   //--- Doji candlestick setup coefficient
   double            m_doji_coef;
   //--- Marubozu candlestick setup coefficient
   double            m_maribozu_coef;
   //--- Spinning Top candlestick setup coefficient
   double            m_spin_coef;
   //--- Hammer candlestick setup coefficient
   double            m_hummer_coef1;
   double            m_hummer_coef2;
   //--- Sampling range for the preset patterns
   int               m_range_total;
   //--- Period to determine the trend
   int               m_trend_period;
   //--- Found patterns
   int               m_found;
   //--- Occurrence of patterns
   double            m_coincidence;
   //--- Probability of upward or downward movement
   double            m_probability1;
   double            m_probability2;
   //--- Efficiency
   double            m_efficiency1;
   double            m_efficiency2;
   //--- Simple candlestick patterns
   struct CANDLE_STRUCTURE
     {
      double            m_open;
      double            m_high;
      double            m_low;
      double            m_close;                      // OHLC
      TYPE_TREND        m_trend;                      // Trend
      bool              m_bull;                       // Bullish candlestick
      double            m_bodysize;                   // Body size
      TYPE_CANDLESTICK  m_type;                       // Candlestick type
     };
   //--- Pattern efficiency evaluation properties
   struct RATING_SET
     {
      int               m_a_uptrend;
      int               m_b_uptrend;
      int               m_c_uptrend;
      int               m_a_dntrend;
      int               m_b_dntrend;
      int               m_c_dntrend;
     };
public:
                     CPattern(void);
                    ~CPattern(void);
   //--- Set and return weight coefficients
   void              K1(const double k1)                             { m_k1=k1;                       }
   double            K1(void)                                        { return(m_k1);                  }
   void              K2(const double k2)                             { m_k2=k2;                       }
   double            K2(void)                                        { return(m_k2);                  }
   void              K3(const double k3)                             { m_k3=k3;                       }
   double            K3(void)                                        { return(m_k3);                  }
   //--- Set and return the threshold trend value
   void              Threshold(const int threshold)                  { m_threshold_value=threshold;   }
   int               Threshold(void)                                 { return(m_threshold_value);     }
   //--- Set and return the long candlestick setup coefficient
   void              Long_coef(const double long_coef)               { m_long_coef=long_coef;         }
   double            Long_coef(void)                                 { return(m_long_coef);           }
   //--- Set and return the short candlestick setup coefficient
   void              Short_coef(const double short_coef)             { m_short_coef=short_coef;       }
   double            Short_coef(void)                                { return(m_short_coef);          }
   //--- Set and return the doji candlestick setup coefficient
   void              Doji_coef(const double doji_coef)               { m_doji_coef=doji_coef;         }
   double            Doji_coef(void)                                 { return(m_doji_coef);           }
   //--- Set and return the marubozu candlestick setup coefficient
   void              Maribozu_coef(const double maribozu_coef)       { m_maribozu_coef=maribozu_coef; }
   double            Maribozu_coef(void)                             { return(m_maribozu_coef);       }
   //--- Set and return the Spinning Top candlestick setup coefficient
   void              Spin_coef(const double spin_coef)               { m_spin_coef=spin_coef;         }
   double            Spin_coef(void)                                 { return(m_spin_coef);           }
   //--- Set and return the Hammer candlestick setup coefficient
   void              Hummer_coef1(const double hummer_coef1)         { m_hummer_coef1=hummer_coef1;   }
   void              Hummer_coef2(const double hummer_coef2)         { m_hummer_coef2=hummer_coef2;   }
   double            Hummer_coef1(void)                              { return(m_hummer_coef1);        }
   double            Hummer_coef2(void)                              { return(m_hummer_coef2);        }
   //--- Set and return the sampling range for preset parameters
   void              Range(const int range_total)                    { m_range_total=range_total;     }
   int               Range(void)                                     { return(m_range_total);         }
   //--- Set and return the number of candlesticks for trend calculation  
   void              TrendPeriod(const int period)                   { m_trend_period=period;         }
   int               TrendPeriod(void)                               { return(m_trend_period);        }
   //--- Returns the selected candlestick type
   TYPE_CANDLESTICK  CandleType(const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift);
   //--- Recognizing the pattern type
   bool              PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,int shift);
   bool              PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index,const int shift);
   bool              PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,const int shift);
   bool              PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3,const int shift);
   //--- Recognizing the set of patterns
   bool              PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN &pattern[],int shift);
   //--- Returns the number of found patterns of the specified type
   int               Found(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern);
   int               Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index);
   int               Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2);
   int               Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3);
   //--- Returns the frequency of the pattern occurrence
   double            Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern);
   double            Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index);
   double            Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2);
   double            Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3);
   //--- Returns the probability of movement after the given pattern 
   double            Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,TYPE_TREND trend);
   double            Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,int index,TYPE_TREND trend);
   double            Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,TYPE_TREND trend);
   double            Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3,TYPE_TREND trend);
   //--- Returns the pattern efficiency coefficient 
   double            Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,TYPE_TREND trend);
   double            Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index,TYPE_TREND trend);
   double            Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,TYPE_TREND trend);
   double            Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3,TYPE_TREND trend);
private:
   //--- Recognizes candlestick type
   bool              GetCandleType(const string symbol,const ENUM_TIMEFRAMES timeframe,CANDLE_STRUCTURE &res,const int shift);
   //--- Calculates coefficients 
   bool              CoefCalculation(RATING_SET &rate,int found);
   //--- Gets statistics on the given pattern
   void              PatternStat(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern);
   void              PatternStat(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3);
   //--- Checks and returns the pattern type
   TYPE_PATTERN      CheckPattern(const string symbol,const ENUM_TIMEFRAMES timeframe,int shift);
   //--- Determines the profitability category of the specified pattern
   bool              GetCategory(const string symbol,const ENUM_TIMEFRAMES timeframe,RATING_SET &rate,int shift);
   //--- Converts the candlestick index to its type
   void              IndexToPatternType(CANDLE_STRUCTURE &res,int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPattern::CPattern(void) : m_k1(1),
                           m_k2(0.5),
                           m_k3(0.25),
                           m_threshold_value(100),
                           m_long_coef(1.3),
                           m_short_coef(0.5),
                           m_doji_coef(0.04),
                           m_maribozu_coef(0.01),
                           m_spin_coef(1),
                           m_hummer_coef1(0.1),
                           m_hummer_coef2(2),
                           m_range_total(8000),
                           m_trend_period(5)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPattern::~CPattern(void)
  {
  }
//+------------------------------------------------------------------+
//| Returns the type of the selected candlestick                     |
//+------------------------------------------------------------------+
TYPE_CANDLESTICK CPattern::CandleType(const string symbol,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   CANDLE_STRUCTURE res;
   if(GetCandleType(symbol,timeframe,res,shift))
      return(res.m_type);
   return(CAND_NONE);
  }
//+------------------------------------------------------------------+
//| Candlestick type recognition                                     |
//+------------------------------------------------------------------+
bool CPattern::GetCandleType(const string symbol,const ENUM_TIMEFRAMES timeframe,CANDLE_STRUCTURE &res,const int shift)
  {
   MqlRates rt[];
   int aver_period=m_trend_period;
   double aver=0;
   int copied=CopyRates(symbol,timeframe,shift,aver_period+1,rt);
//--- Get details of the previous candlestick
   if(copied<aver_period)
      return(false);
//---
   res.m_open=rt[aver_period].open;
   res.m_high=rt[aver_period].high;
   res.m_low=rt[aver_period].low;
   res.m_close=rt[aver_period].close;

//--- Determine the trend direction
   for(int i=0;i<aver_period;i++)
      aver+=rt[i].close;
   aver/=aver_period;

   if(aver<res.m_close)
      res.m_trend=UPPER;
   if(aver>res.m_close)
      res.m_trend=DOWN;
   if(aver==res.m_close)
      res.m_trend=FLAT;
//--- Determine if it is a bullish or a bearish candlestick
   res.m_bull=res.m_open<res.m_close;
//--- Get the absolute size of candlestick body
   res.m_bodysize=MathAbs(res.m_open-res.m_close);
//--- Get sizes of shadows
   double shade_low=res.m_close-res.m_low;
   double shade_high=res.m_high-res.m_open;
   if(res.m_bull)
     {
      shade_low=res.m_open-res.m_low;
      shade_high=res.m_high-res.m_close;
     }
   double HL=res.m_high-res.m_low;
//--- Calculate average body size of previous candlesticks
   double sum=0;
   for(int i=1; i<=aver_period; i++)
      sum+=MathAbs(rt[i].open-rt[i].close);
   sum/=aver_period;

//--- Determine the candlestick type   
   res.m_type=CAND_NONE;
//--- long 
   if(res.m_bodysize>sum*m_long_coef)
      res.m_type=CAND_LONG;
//--- sort 
   if(res.m_bodysize<sum*m_short_coef)
      res.m_type=CAND_SHORT;
//--- doji
   if(res.m_bodysize<HL*m_doji_coef)
      res.m_type=CAND_DOJI;
//--- marubozu
   if((shade_low<res.m_bodysize*m_maribozu_coef || shade_high<res.m_bodysize*m_maribozu_coef) && res.m_bodysize>0)
      res.m_type=CAND_MARIBOZU;
//--- hammer
   if(shade_low>res.m_bodysize*m_hummer_coef2 && shade_high<res.m_bodysize*m_hummer_coef1)
      res.m_type=CAND_HAMMER;
//--- invert hammer
   if(shade_low<res.m_bodysize*m_hummer_coef1 && shade_high>res.m_bodysize*m_hummer_coef2)
      res.m_type=CAND_INVERT_HAMMER;
//--- spinning top
   if(res.m_type==CAND_SHORT && shade_low>res.m_bodysize*m_spin_coef && shade_high>res.m_bodysize*m_spin_coef)
      res.m_type=CAND_SPIN_TOP;
//---
   ArrayFree(rt);
   return(true);
  }
//+------------------------------------------------------------------+
//| Recognizing a pre-defined pattern                                |
//+------------------------------------------------------------------+
bool CPattern::PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,const int shift)
  {
   if(CheckPattern(symbol,timeframe,shift)==pattern)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Recognizing a pattern by candlestick index                       |
//+------------------------------------------------------------------+
bool CPattern::PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index,int shift)
  {
//--- Verify the candlestick index
   if(index<0 || index>11)
      return(false);
//---
   CANDLE_STRUCTURE cand,cur_cand;
   RATING_SET ratings;
   ZeroMemory(cand);
   IndexToPatternType(cand,index);
//--- Get the current candlestick type
   GetCandleType(symbol,timeframe,cur_cand,shift);                                // Current candlestick
//---
   if(cur_cand.m_type==cand.m_type && cur_cand.m_bull==cand.m_bull)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Recognizing a pattern by candlestick index                       |
//+------------------------------------------------------------------+
bool CPattern::PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int shift)
  {
//--- Verify the candlestick index
   if(index1<0 || index1>11 || index2<0 || index2>11)
      return(false);
//---
   CANDLE_STRUCTURE cand1,cand2,cand3,cur_cand,prev_cand;
   RATING_SET ratings;
   ZeroMemory(cand1);
   ZeroMemory(cand2);
   IndexToPatternType(cand1,index1);
   IndexToPatternType(cand2,index2);
//--- Get the current candlestick type
   GetCandleType(symbol,timeframe,prev_cand,shift+1);                               // Previous candlestick
   GetCandleType(symbol,timeframe,cur_cand,shift);                                // Current candlestick
//---
   if(cur_cand.m_type==cand1.m_type && cur_cand.m_bull==cand1.m_bull && 
      prev_cand.m_type==cand2.m_type && prev_cand.m_bull==cand2.m_bull)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Recognizing a pattern by candlestick index                       |
//+------------------------------------------------------------------+
bool CPattern::PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3,int shift)
  {
   CANDLE_STRUCTURE cand1,cand2,cand3,cur_cand,prev_cand,prev_cand2;
   RATING_SET ratings;
//---
   ZeroMemory(cand1);
   ZeroMemory(cand2);
   ZeroMemory(cand3);
//---
   IndexToPatternType(cand1,index1);
   IndexToPatternType(cand2,index2);
   IndexToPatternType(cand3,index3);

//--- Get the current candlestick type
   GetCandleType(symbol,timeframe,prev_cand2,shift+2);                              // Previous candlestick
   GetCandleType(symbol,timeframe,prev_cand,shift+1);                               // Previous candlestick
   GetCandleType(symbol,timeframe,cur_cand,shift);                                // Current candlestick
//---
   if(cur_cand.m_type==cand1.m_type && cur_cand.m_bull==cand1.m_bull && 
      prev_cand.m_type==cand2.m_type && prev_cand.m_bull==cand2.m_bull && 
      prev_cand2.m_type==cand3.m_type && prev_cand2.m_bull==cand3.m_bull)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Recognizing an array of patterns                                 |
//+------------------------------------------------------------------+
bool CPattern::PatternType(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN &pattern[],int shift)
  {
   for(int i=0;i<ArraySize(pattern);i++)
     {
      if(CheckPattern(symbol,timeframe,shift)==pattern[i])
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Get statistics on the given pattern                              |
//+------------------------------------------------------------------+
CPattern::PatternStat(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern)
  {
//---
   int pattern_counter=0;
//---
   RATING_SET pattern_coef={0,0,0,0,0,0};
//---
   for(int i=m_range_total;i>4;i--)
     {
      if(CheckPattern(symbol,timeframe,i)==pattern)
        {
         pattern_counter++;
         if(pattern==HUMMER || pattern==INVERT_HUMMER || pattern==HANDING_MAN)
            GetCategory(symbol,timeframe,pattern_coef,i-3);
         else
            GetCategory(symbol,timeframe,pattern_coef,i-4);
        }
     }
//---
   CoefCalculation(pattern_coef,pattern_counter);
  }
//+------------------------------------------------------------------+
//| Get statistics on the given pattern                              |
//+------------------------------------------------------------------+
void CPattern::PatternStat(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2=0,int index3=0)
  {
   CANDLE_STRUCTURE cand1,cand2,cand3,cur_cand,prev_cand,prev_cand2;
   RATING_SET rating={0,0,0,0,0,0};
   int pattern_total=0,pattern_size=1;
//---
   ZeroMemory(cand1);
   ZeroMemory(cand2);
   ZeroMemory(cand3);
   ZeroMemory(cur_cand);
   ZeroMemory(prev_cand);
   ZeroMemory(prev_cand2);
//---
   if(index2>0)
      pattern_size=2;
   if(index3>0)
      pattern_size=3;
//---
   if(pattern_size==1)
      IndexToPatternType(cand1,index1);
   else if(pattern_size==2)
     {
      IndexToPatternType(cand1,index1);
      IndexToPatternType(cand2,index2);
     }
   else if(pattern_size==3)
     {
      IndexToPatternType(cand1,index1);
      IndexToPatternType(cand2,index2);
      IndexToPatternType(cand3,index3);
     }
//---
   for(int i=m_range_total;i>5;i--)
     {
      if(pattern_size==1)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,timeframe,cur_cand,i);                                       // Current candlestick
         //---
         if(cur_cand.m_type==cand1.m_type && cur_cand.m_bull==cand1.m_bull)
           {
            pattern_total++;
            GetCategory(symbol,timeframe,rating,i-3);
           }
        }
      else if(pattern_size==2)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,timeframe,prev_cand,i);                                        // Previous candlestick
         GetCandleType(symbol,timeframe,cur_cand,i-1);                                       // Current candlestick
         //---

         if(cur_cand.m_type==cand1.m_type && cur_cand.m_bull==cand1.m_bull && 
            prev_cand.m_type==cand2.m_type && prev_cand.m_bull==cand2.m_bull)
           {
            pattern_total++;
            GetCategory(symbol,timeframe,rating,i-4);
           }
        }
      else if(pattern_size==3)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,timeframe,prev_cand2,i);                                       // Previous candlestick
         GetCandleType(symbol,timeframe,prev_cand,i-1);                                      // Previous candlestick
         GetCandleType(symbol,timeframe,cur_cand,i-2);                                       // Current candlestick
         //---
         if(cur_cand.m_type==cand1.m_type && cur_cand.m_bull==cand1.m_bull && 
            prev_cand.m_type==cand2.m_type && prev_cand.m_bull==cand2.m_bull && 
            prev_cand2.m_type==cand3.m_type && prev_cand2.m_bull==cand3.m_bull)
           {
            pattern_total++;
            GetCategory(symbol,timeframe,rating,i-5);
           }
        }
     }
//---
   CoefCalculation(rating,pattern_total);
  }
//+------------------------------------------------------------------+
//| Converts the candlestick index to its type                       |
//+------------------------------------------------------------------+
void CPattern::IndexToPatternType(CANDLE_STRUCTURE &res,int index)
  {
//--- Long - bullish
   if(index==1)
     {
      res.m_bull=true;
      res.m_type=CAND_LONG;
     }
//--- Long - bearish
   else if(index==2)
     {
      res.m_bull=false;
      res.m_type=CAND_LONG;
     }
//--- Short - bullish
   else if(index==3)
     {
      res.m_bull=true;
      res.m_type=CAND_SHORT;
     }
//--- Short - bearish
   else if(index==4)
     {
      res.m_bull=false;
      res.m_type=CAND_SHORT;
     }
//--- Spinning Top - bullish
   else if(index==5)
     {
      res.m_bull=true;
      res.m_type=CAND_SPIN_TOP;
     }
//--- Spinning Top - bearish
   else if(index==6)
     {
      res.m_bull=false;
      res.m_type=CAND_SPIN_TOP;
     }
//--- Doji
   else if(index==7)
     {
      res.m_bull=true;
      res.m_type=CAND_DOJI;
     }
//--- Marubozu - bullish
   else if(index==8)
     {
      res.m_bull=true;
      res.m_type=CAND_MARIBOZU;
     }
//--- Marubozu - bearish
   else if(index==9)
     {
      res.m_bull=false;
      res.m_type=CAND_MARIBOZU;
     }
//--- Hammer - bullish
   else if(index==10)
     {
      res.m_bull=true;
      res.m_type=CAND_HAMMER;
     }
//--- Hammer - bearish
   else if(index==11)
     {
      res.m_bull=false;
      res.m_type=CAND_HAMMER;
     }
  }
//+------------------------------------------------------------------+
//| Calculate efficiency assessment coefficients                     |
//+------------------------------------------------------------------+
bool CPattern::CoefCalculation(RATING_SET &rate,int found)
  {
   int sum1=0,sum2=0;
   sum1=rate.m_a_uptrend+rate.m_b_uptrend+rate.m_c_uptrend;
   sum2=rate.m_a_dntrend+rate.m_b_dntrend+rate.m_c_dntrend;
//---
   m_probability1=(found>0)?NormalizeDouble((double)sum1/found*100,2):0;
   m_probability2=(found>0)?NormalizeDouble((double)sum2/found*100,2):0;
   m_efficiency1=(found>0)?NormalizeDouble((m_k1*rate.m_a_uptrend+m_k2*rate.m_b_uptrend+m_k3*rate.m_c_uptrend)/found,3):0;
   m_efficiency2=(found>0)?NormalizeDouble((m_k1*rate.m_a_dntrend+m_k2*rate.m_b_dntrend+m_k3*rate.m_c_dntrend)/found,3):0;
   m_found=found;
   m_coincidence=((double)found/m_range_total*100);
   return(true);
  }
//+------------------------------------------------------------------+
//| Determine profit categories                                      |
//+------------------------------------------------------------------+
bool CPattern::GetCategory(const string symbol,const ENUM_TIMEFRAMES timeframe,RATING_SET &rate,int shift)
  {
   MqlRates rt[];
   int copied=CopyRates(symbol,timeframe,shift,4,rt);
//--- Get details of the previous candlestick
   if(copied<4)
      return(false);
   double high1,high2,high3,low1,low2,low3,close0,point;
   close0=rt[0].close;
   high1=rt[1].high;
   high2=rt[2].high;
   high3=rt[3].high;
   low1=rt[1].low;
   low2=rt[2].low;
   low3=rt[3].low;
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(false);

//--- Check if it is the Uptrend
   if((int)((high1-close0)/point)>=m_threshold_value)
     {
      rate.m_a_uptrend++;
     }
   else if((int)((high2-close0)/point)>=m_threshold_value)
     {
      rate.m_b_uptrend++;
     }
   else if((int)((high3-close0)/point)>=m_threshold_value)
     {
      rate.m_c_uptrend++;
     }

//--- Check if it is the Downtrend
   if((int)((close0-low1)/point)>=m_threshold_value)
     {
      rate.m_a_dntrend++;
     }
   else if((int)((close0-low2)/point)>=m_threshold_value)
     {
      rate.m_b_dntrend++;
     }
   else if((int)((close0-low3)/point)>=m_threshold_value)
     {
      rate.m_c_dntrend++;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns the number of found patterns of the specified type       |
//+------------------------------------------------------------------+
int CPattern::Found(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern)
  {
   PatternStat(symbol,timeframe,pattern);
   return(m_found);
  }
//+------------------------------------------------------------------+
//| Returns the number of found patterns of the specified type       |
//+------------------------------------------------------------------+
int CPattern::Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1)
  {
   PatternStat(symbol,timeframe,index1);
   return(m_found);
  }
//+------------------------------------------------------------------+
//| Returns the number of found patterns of the specified type       |
//+------------------------------------------------------------------+
int CPattern::Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2)
  {
   PatternStat(symbol,timeframe,index1,index2);
   return(m_found);
  }
//+------------------------------------------------------------------+
//| Returns the number of found patterns of the specified type       |
//+------------------------------------------------------------------+
int CPattern::Found(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3)
  {
   PatternStat(symbol,timeframe,index1,index2,index3);
   return(m_found);
  }
//+------------------------------------------------------------------+
//| Returns the frequency of the pattern occurrence                  |
//+------------------------------------------------------------------+
double CPattern::Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern)
  {
   PatternStat(symbol,timeframe,pattern);
   return(m_coincidence);
  }
//+------------------------------------------------------------------+
//| Returns the frequency of the pattern occurrence                  |
//+------------------------------------------------------------------+
double CPattern::Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1)
  {
   PatternStat(symbol,timeframe,index1);
   return(m_coincidence);
  }
//+------------------------------------------------------------------+
//| Returns the frequency of the pattern occurrence                  |
//+------------------------------------------------------------------+
double CPattern::Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2)
  {
   PatternStat(symbol,timeframe,index1,index2);
   return(m_coincidence);
  }
//+------------------------------------------------------------------+
//| Returns the frequency of the pattern occurrence                  |
//+------------------------------------------------------------------+
double CPattern::Coincidence(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3)
  {
   PatternStat(symbol,timeframe,index1,index2,index3);
   return(m_coincidence);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,pattern);
   if(trend==UPPER)
      return(m_probability1);
   if(trend==DOWN)
      return(m_probability2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,index1);
   if(trend==UPPER)
      return(m_probability1);
   if(trend==DOWN)
      return(m_probability2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Probability(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,index1,index2);
   if(trend==UPPER)
      return(m_probability1);
   if(trend==DOWN)
      return(m_probability2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,TYPE_PATTERN pattern,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,pattern);
   if(trend==UPPER)
      return(m_efficiency1);
   if(trend==DOWN)
      return(m_efficiency2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,index1);
   if(trend==UPPER)
      return(m_efficiency1);
   if(trend==DOWN)
      return(m_efficiency2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,index1,index2);
   if(trend==UPPER)
      return(m_efficiency1);
   if(trend==DOWN)
      return(m_efficiency2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Returns the probability of movement after the given pattern      |
//+------------------------------------------------------------------+
double CPattern::Efficiency(const string symbol,const ENUM_TIMEFRAMES timeframe,int index1,int index2,int index3,TYPE_TREND trend)
  {
   PatternStat(symbol,timeframe,index1,index2,index3);
   if(trend==UPPER)
      return(m_efficiency1);
   if(trend==DOWN)
      return(m_efficiency2);
   return(0);
  }
//+------------------------------------------------------------------+
//| Checks and returns the pattern type                              |
//+------------------------------------------------------------------+
TYPE_PATTERN CPattern::CheckPattern(const string symbol,const ENUM_TIMEFRAMES timeframe,int shift)
  {
   CANDLE_STRUCTURE cand1,cand2;
   TYPE_PATTERN pattern=NONE;
   ZeroMemory(cand1);
   ZeroMemory(cand2);
   GetCandleType(symbol,timeframe,cand2,shift+1);                                           // Previous candlestick
   GetCandleType(symbol,timeframe,cand1,shift);                                         // Current candlestick
//--- Inverted Hammer, bullish model
   if(cand2.m_trend==DOWN &&                                                              // Checking the trend direction
      cand2.m_type==CAND_INVERT_HAMMER)                                                   // Checking the "Inverted Hammer"
      pattern=INVERT_HUMMER;
//--- Hanging man, bearish
   else if(cand2.m_trend==UPPER && // Checking the trend direction
      cand2.m_type==CAND_HAMMER) // Checking "Hammer"
      pattern=HANDING_MAN;
//--- Hammer, bullish model
   else if(cand2.m_trend==DOWN && // Checking the trend direction
      cand2.m_type==CAND_HAMMER) // Checking "Hammer"
      pattern=HUMMER;
//--- Shooting Star, bearish model
   else if(cand1.m_trend==UPPER && cand2.m_trend==UPPER && // Checking the trend direction
      cand2.m_type==CAND_INVERT_HAMMER && cand1.m_close<=cand2.m_open) // Checking "Inverted Hammer"
      pattern=SHOOTING_STAR;
//--- Engulfing, bullish model
   else if(cand1.m_trend==DOWN && cand1.m_bull && cand2.m_trend==DOWN && !cand2.m_bull && // Checking trend direction and candlestick direction
      cand1.m_close>=cand2.m_open && cand1.m_open<cand2.m_close)
      pattern=ENGULFING_BULL;
//--- Engulfing, bearish model
   else if(cand1.m_trend==UPPER && cand1.m_bull && cand2.m_trend==UPPER && !cand2.m_bull && // Checking trend direction and candlestick direction
      cand1.m_close<=cand2.m_open && cand1.m_open>cand2.m_close)
      pattern=ENGULFING_BEAR;
//--- Harami Cross, bullish
   else if(cand2.m_trend==DOWN && !cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && cand1.m_type==CAND_DOJI && // Checking the "long" first candlestick and the doji candlestick
      cand1.m_close<cand2.m_open && cand1.m_open>=cand2.m_close) // Doji is inside the first candlestick body
      pattern=HARAMI_CROSS_BULL;
//--- Harami Cross, bearish model
   else if(cand2.m_trend==UPPER && cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && cand1.m_type==CAND_DOJI && // Checking the "long" candlestick and the doji candlestick
      cand1.m_close>cand2.m_open && cand1.m_open<=cand2.m_close) // Doji is inside the first candlestick body 
      pattern=HARAMI_CROSS_BEAR;
//--- Harami, bullish
   else if(cand1.m_trend==DOWN && cand1.m_bull && !cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && // Checking the "long" first candlestick
      cand1.m_type!=CAND_DOJI && cand1.m_bodysize<cand2.m_bodysize && // The second candle is not Doji and first candlestick body is larger than that of the second one
                    cand1.m_close<cand2.m_open && cand1.m_open>=cand2.m_close) // Second candlestick body is inside the first candlestick body 
                    pattern=HARAMI_BULL;
//--- Harami, bearish
   else if(cand1.m_trend==UPPER && !cand1.m_bull && cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && // Checking the "long" first candlestick
      cand1.m_type!=CAND_DOJI && cand1.m_bodysize<cand2.m_bodysize && // The second candle is not Doji and first candlestick body is larger than that of the second one
                    cand1.m_close>cand2.m_open && cand1.m_open<=cand2.m_close) // Doji is inside the first candlestick body 
                    pattern=HARAMI_BEAR;
//--- Doji Star, bullish
   else if(cand1.m_trend==DOWN && !cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && cand1.m_type==CAND_DOJI && // Checking the 1st "long" candlestick and the 2nd doji
      cand1.m_close<=cand2.m_open) // Doji Open is lower or equal to 1st candle Close 
      pattern=DOJI_STAR_BULL;
//--- Doji Star, bearish
   else if(cand1.m_trend==UPPER && cand2.m_bull && // Checking trend direction and candlestick direction
      (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && cand1.m_type==CAND_DOJI && // Checking the 1st "long" candlestick and the 2nd doji
      cand1.m_open>=cand2.m_close) //Doji Open price is higher or equal to 1st candle Close
      pattern=DOJI_STAR_BEAR;
//--- Piercing, bullish model
   else if(cand1.m_trend==DOWN && cand1.m_bull && !cand2.m_bull && // Checking trend direction and candlestick direction
      (cand1.m_type==CAND_LONG || cand1.m_type==CAND_MARIBOZU) && (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && // Checking the "long" candlestick
      cand1.m_close>(cand2.m_close+cand2.m_open)/2 && // 2nd candle Close is above the middle of the 1st candlestick
      cand2.m_open>cand1.m_close && cand2.m_close>=cand1.m_open)
      pattern=PIERCING_LINE;
//--- Dark Cloud Cover, bearish
   else if(cand1.m_trend==UPPER && !cand1.m_bull && cand2.m_bull && // Checking trend direction and candlestick direction
      (cand1.m_type==CAND_LONG || cand1.m_type==CAND_MARIBOZU) && (cand2.m_type==CAND_LONG || cand2.m_type==CAND_MARIBOZU) && // Checking the "long" candlestick
      cand1.m_close<(cand2.m_close+cand2.m_open)/2 && // Close 2 is below the middle of the 1st candlestick body
      cand1.m_close<cand2.m_open && cand2.m_close<=cand1.m_open)
      pattern=DARK_CLOUD_COVER;
   return(pattern);
  }
//+------------------------------------------------------------------+
