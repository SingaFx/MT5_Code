//+------------------------------------------------------------------+
//|                                                   math_tools.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Math\Alglib\matrix.mqh>

class czj_tools
  {
public:
                     czj_tools(void){};
                    ~czj_tools(void){};
                    static void RMatrixMultiply(const CMatrixDouble &cm1,const CMatrixDouble &cm2, CMatrixDouble &cm_res);
  };
static void czj_tools::RMatrixMultiply(const CMatrixDouble &cm1,const CMatrixDouble &cm2,CMatrixDouble &cm_res)
   {
    int row1=cm1.Size();
    int col1=cm1[0].Size();
    int row2=cm2.Size();
    int col2=cm2[0].Size();
    if(col1!=row2) return;
    cm_res.Resize(row1,col2);
    for(int i=0;i<row1;i++)
      {
       for(int j=0;j<col2;j++)
         {
          double sum=0;
          for(int k=0;k<col1;k++)
            {
             sum+=cm1[i][k]*cm2[k][j];
            }
          cm_res[i].Set(j,sum);
         }
      }
   }