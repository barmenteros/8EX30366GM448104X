//+------------------------------------------------------------------+
//|                                Copyright © 2018, barmenteros.com |
//|                                     support.team@barmenteros.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, barmenteros.com"
#property link      "http://barmenteros.com"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_plots 0

extern double Risk = 3.0;
extern int AlertMode=0;
       
       string sM_="ALERTS SETTINGS";//.
       bool AllAlertsOff =false; //Turn off all alerts
extern bool DialogBoxAlert =true; //Enable dialog box alert
       bool EmailAlert =false; //Send email as alert
       bool SMSAlert =false; //Send SMS as alert
       bool SoundAlert =false; //Play a sound as alert
       string SoundFile ="alert.wav"; //Sound to be played

//+------------------------------------------------------------------+
//| TimeFrameToString function
//+------------------------------------------------------------------+
string TimeFrameToString (const int i_tmfrm, const bool b_short_mode=true)
{
      switch (i_tmfrm)
      {
            case PERIOD_M1: return(b_short_mode?"M1":"1 minute");
            case PERIOD_M5: return(b_short_mode?"M5":"5 minutes");
            case PERIOD_M15: return(b_short_mode?"M15":"15 minutes");
            case PERIOD_M30: return(b_short_mode?"M30":"30 minutes");
            case PERIOD_H1: return(b_short_mode?"H1":"1 hour");
            case PERIOD_H4: return(b_short_mode?"H4":"4 hours");
            case PERIOD_D1: return(b_short_mode?"D1":"Daily");
            case PERIOD_W1: return(b_short_mode?"W1":"Weekly");
            case PERIOD_MN1: return(b_short_mode?"MN1":"Monthly");
            case 0: return(b_short_mode?"Current":"Current TF");
            default: return(__FUNCTION__+" » "+(string)i_tmfrm+
               " timeframe not available");
      }
}
//+------------------------------------------------------------------+
//| SetAlerts function
//+------------------------------------------------------------------+
void SetAlerts (const string s_ord_type, const bool b_all_off=false, 
                const bool b_popup_alrt=false, const bool b_email_alrt=false, 
                const bool b_sms_alrt=false, const bool b_sound_alrt=false, 
                const string b_sound="alert.wav")
{
      if (!b_all_off) {
            if (b_popup_alrt)
                  Alert (s_ord_type," signal at ",_Symbol," ",
                     TimeFrameToString(_Period));
            if (!b_popup_alrt &&
                b_sound_alrt)
                  PlaySound(b_sound);
      }
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
      return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
      
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
      ArraySetAsSeries( time, true );
      ArraySetAsSeries( open, true );
      ArraySetAsSeries( high, true );
      ArraySetAsSeries( low, true );
      ArraySetAsSeries( close, true );
      ArraySetAsSeries( tick_volume, true );
      ArraySetAsSeries( volume, true );
      ArraySetAsSeries( spread, true );

      bool b_IsNewBar = true;
//      b_IsNewBar = IsNewBar (CURRENT_BAR_NO_NEW);
      if (b_IsNewBar) {
            static datetime sdt_PreviousBuyTime = 0;
            static datetime sdt_PreviousSellTime = 0;
            double d_Up_1 = 0.0,
                   d_Dn_1 = 0.0;
            d_Up_1 = iCustom (NULL,0, "price channel signal", 
               Risk, AlertMode,
               0, 0);
            d_Dn_1 = iCustom (NULL,0, "price channel signal", 
               Risk, AlertMode,
               1, 0);
            d_Up_1 = NormalizeDouble (d_Up_1, _Digits);
            d_Dn_1 = NormalizeDouble (d_Dn_1, _Digits);
            if (d_Up_1 > NormalizeDouble (0.0, _Digits) &&
                d_Up_1 != EMPTY_VALUE &&
                time[0] > sdt_PreviousBuyTime) {
                  sdt_PreviousBuyTime = time[0];
                  SetAlerts ("BUY", AllAlertsOff, DialogBoxAlert, 
                     EmailAlert, SMSAlert, SoundAlert, SoundFile);
            }
            if (d_Dn_1 > NormalizeDouble (0.0, _Digits) &&
                d_Dn_1 != EMPTY_VALUE &&
                time[0] > sdt_PreviousSellTime) {
                  sdt_PreviousSellTime = time[0];
                  SetAlerts ("SELL", AllAlertsOff, DialogBoxAlert, 
                     EmailAlert, SMSAlert, SoundAlert, SoundFile);
            }
      }

      //---- return value of prev_calculated for next call
      return(rates_total);
}
//+------------------------------------------------------------------+