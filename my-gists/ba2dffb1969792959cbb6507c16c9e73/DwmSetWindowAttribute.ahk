#Requires AutoHotkey v2

/**
 * Sets the value of Desktop Window Manager (DWM) non-client rendering attributes for a window. For programming guidance, and code examples, see Controlling non-client region rendering.
 * @param hwnd The handle to the window for which the attribute value is to be set.  
 * @param dwAttribute A flag describing which value to set, specified as a value of the [DWMWINDOWATTRIBUTE](https://learn.microsoft.com/en-us/windows/desktop/api/dwmapi/ne-dwmapi-dwmwindowattribute) enumeration. This parameter specifies which attribute to set, and the pvAttribute parameter points to an object containing the attribute value.
 *  
 * > ___| prop
 * > :-:|:-----------------------------------------
 * > 1  | ~DWMWA_NCRENDERING_ENABLED~           
 * > 2  | `DWMWA_NCRENDERING_POLICY`
 * >    |    | 0. `DWMNCRP_USEWINDOWSTYLE`
 * >    |    | 1. `DWMNCRP_DISABLED`
 * >    |    | 2. `DWMNCRP_ENABLED`
 * >    |    | 3. `DWMNCRP_LAST`
 * > 3  | `DWMWA_TRANSITIONS_FORCEDISABLED`     
 * > 4  | `DWMWA_ALLOW_NCPAINT`
 * > 5  | ~DWMWA_CAPTION_BUTTON_BOUNDS~         
 * > 6  | `DWMWA_NONCLIENT_RTL_LAYOUT`          
 * > 7  | `DWMWA_FORCE_ICONIC_REPRESENTATION`   
 * > 8  | `DWMWA_FLIP3D_POLICY`                 
 * > 9  | ~DWMWA_EXTENDED_FRAME_BOUNDS~         
 * > 10 | `DWMWA_HAS_ICONIC_BITMAP`             
 * > 11 | `DWMWA_DISALLOW_PEEK`                 
 * > 12 | `DWMWA_EXCLUDED_FROM_PEEK`            
 * > 13 | `DWMWA_CLOAK`                         
 * > 14 | ~DWMWA_CLOAKED~                       
 * > 15 | `DWMWA_FREEZE_REPRESENTATION`         
 * > 16 | `DWMWA_PASSIVE_UPDATE_MODE`           
 * > 17 | `DWMWA_USE_HOSTBACKDROPBRUSH`         
 * > 20 | `DWMWA_USE_IMMERSIVE_DARK_MODE`       
 * > 33 | `DWMWA_WINDOW_CORNER_PREFERENCE` 
 * >    |    | 0.  `DWMWCP_DEFAULT`
 * >    |    | 1.  `DWMWCP_DONOTROUND`
 * >    |    | 2.  `DWMWCP_ROUND`
 * >    |    | 3.  `DWMWCP_ROUNDSMALL`
 * > 34 | `DWMWA_BORDER_COLOR`                      
 * > 35 | `DWMWA_CAPTION_COLOR`                     
 * > 36 | `DWMWA_TEXT_COLOR`                        
 * > 37 | ~DWMWA_VISIBLE_FRAME_BORDER_THICKNESS~    
 * > 38 | `DWMWA_SYSTEMBACKDROP_TYPE`  
 * >    |   | 0. `DWMSBT_AUTO`    
 * >    |   | 1. `DWMSBT_NONE`    
 * >    |   | 2. `DWMSBT_MAINWINDOW`    
 * >    |   | 3. `DWMSBT_TRANSIENTWINDOW`    
 * >    |   | 4. `DWMSBT_TABBEDWINDOW`
 * > ---------------------------------------------
 * 
 * @param pvAttribute  
 * A pointer to an object containing the attribute value to set. The type of the value set depends on the value of the dwAttribute parameter. The [DWMWINDOWATTRIBUTE](https://learn.microsoft.com/en-us/windows/desktop/api/dwmapi/ne-dwmapi-dwmwindowattribute) enumeration topic indicates, in the row for each flag, what type of value you should pass a pointer to in the pvAttribute parameter.  
 * @param {interger} cbAttribute The size, in bytes, of the attribute value being set via the pvAttribute parameter. The type of the value set, and therefore its size in bytes, depends on the value of the dwAttribute parameter.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute
 * @returns {float|integer|string} 
 */
DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute := 4) => DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr" , hwnd, "UInt", dwAttribute, "Ptr*", &pvAttribute, "UInt", cbAttribute)
