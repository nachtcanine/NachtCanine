package com.thinking.plugins;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import java.net.SocketException;

/**
 * This class echoes a string called from JavaScript.
 */
public class NachtCanine extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("sendInfo")) {
            String ip = args.getString(0);
            int port =Integer.parseInt(args.getString(1));
            String sendInfoStr = args.getString(2);
            sendInfo(ip,port,sendInfoStr, callbackContext);
            return true;
        }
        if (action.equals("testInfo")) {
            String teststring = args.getString(0);
            testInfo(teststring, callbackContext);
            return true;
        }
        return false;
    }
    
    private void testInfo(String teststring,CallbackContext callbackContext) {
        callbackContext.success(teststring);
    }
    
    private void sendInfo(String ip, int port, String sendInfoStr,CallbackContext callbackContext) {
        callbackContext.success("GOOD");
        /*try
         {
             
            String[] sendInfos = sendInfoStr.split(";");
            for (String info : sendInfos) {
                Socket socket = new Socket(ip, port);
                OutputStream outputStream = socket.getOutputStream();
                String[] atInfos = info.split("@");
                if (atInfos.length == 2) {
                    int time = Integer.parseInt(atInfos[1]);
                    Thread.sleep(time * 1000);
                    outputStream.write(hexStr2Str(atInfos[0].replace(" ", "")).getBytes());
                } else if (atInfos.length == 1) {
                    outputStream.write(hexStr2Str(atInfos[0].replace(" ", "")).getBytes());
                } else {
                    throw new Exception("Exception: " + info + ".");
                }
                socket.close();
                outputStream.close();
                callbackContext.success("Send Info Success");
            }
        } catch (SocketException e) {
            callbackContext.error(e.getMessage());
        } catch (IOException e) {
            callbackContext.error(e.getMessage());
        } catch (Exception e) {
           callbackContext.error(e.getMessage());
        }*/
    }
    
    private String hexStr2Str(String hexStr) {
        String str = "0123456789ABCDEF";
        char[] hexs = hexStr.toCharArray();
        byte[] bytes = new byte[hexStr.length() / 2];
        int n;

        for (int i = 0; i < bytes.length; i++) {
            n = str.indexOf(hexs[2 * i]) * 16;
            n += str.indexOf(hexs[2 * i + 1]);
            bytes[i] = (byte)(n & 0xff);
        }
        String str1 = new String(bytes);
        return str1;
    }

}
