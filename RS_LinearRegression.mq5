//+------------------------------------------------------------------+
//|                                          RS_LinearRegression.mq5 |
//|                                                     Smith R., D. |
//|                                            ryan.smithnz@live.com |
//+------------------------------------------------------------------+
#property copyright "Ryan Smith"
#property version "1.00"
#property description "Linear Regression"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_color1 Yellow
#property indicator_applied_price PRICE_CLOSE


//INPUTS

//Number of candles calculated in linear regression line
input int linearRegression_Period = 20; 


//BUFFERS

double buffer_LinearRegression[];


//VARIABLES

//Period used in internal calculations
int period;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
{
   //Setup linear regression buffer
   ArraySetAsSeries(buffer_LinearRegression, true);
   SetIndexBuffer(0, buffer_LinearRegression, INDICATOR_DATA);

   //Get total bars on chart
   int totalBars;
   totalBars = Bars(Symbol(), PERIOD_CURRENT);
   
   //Ensure input of linear regression period is suitable for internal calculations
   if(linearRegression_Period < 2){
      period = 2;
      printf("Incorrect input value linearRegression_Period=%d. Indicator will use linearRegression_Period=%d.", linearRegression_Period, period);
   }
   else if(linearRegression_Period >= totalBars)
   {
      period = totalBars - 1;
      printf("Total Bars=%d. Incorrect input value linearRegression_Period=%d. Indicator will use linearRegression_Period=%d.", totalBars, linearRegression_Period, period);
   }
   else
   {
      period = linearRegression_Period;
   }   
   
   //Add a label to the linear regression line indicator
   PlotIndexSetString(0, PLOT_LABEL, "Linear Regression Line (" + string(period) + ")");   
}
//+------------------------------------------------------------------+
//| Linear Regression                                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,       //price[] array size
                const int prev_calculated,   //number of handled bars at the previous call
                const int begin,             //index number in the price[] array where meaningful data starts from
                const double &price[])       //array of values for calculation
{

    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - period);
    
    ArraySetAsSeries(price, true);

   double sumY = 0.0;
   double sumX = 0.0;
   double sumXY = 0.0;
   double sumX2 = 0.0;
   
   //Create the 'sum' variables  
   for(int i = 0; i < period; i++)
   {
      sumX += i;
      sumY += price[i];
      sumXY += price[i] * i;
      sumX2 += MathPow(i, 2);
   } 
   
   //Use the variables in the linear regression equation
   double c = MathPow(sumX, 2) - period * sumX2;

   double a = (sumX * sumY - period * sumXY) / c;
   double b = (sumY - a * sumX) / period;
   
   //Populate the linear regression line buffers with the line data
   for(int i = 0; i < period; i++)
   {
      buffer_LinearRegression[i] = a * i + b;
   }
      
   return(rates_total);
}