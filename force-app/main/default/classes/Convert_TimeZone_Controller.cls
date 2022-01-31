/*
* Name: Convert_TimeZone_Controller_Test
* Author: Naveen Punyala
* Desc: Class used for the component Convert_TimeZone_Date.vfc
* Date: 12/28/2018
*/

public class Convert_TimeZone_Controller
{
    public DateTime date_time { get; set; }
    public String defined_TimeZone { get; set; }

    public String getFormattedDatetime() {
		if (date_time == null)
        {
			return '';
		}
        else
        {
			if (defined_TimeZone == null)
            {
				return date_time.format();
			}
            else
            {

                return date_time.format('yyyy-MM-dd hh:mm a ',defined_TimeZone);
			}
		}
	}
}