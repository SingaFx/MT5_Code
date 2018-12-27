//+------------------------------------------------------------------+
//|                                                 CurrencyRisk.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

class CCurrencyRisk
  {
private:
   string currencies[];
   double c_lots_long[];
   double c_lots_short[];
   double c_lots_long_to_short[];
public:
                     CCurrencyRisk(void);
                    ~CCurrencyRisk(void);
  };
