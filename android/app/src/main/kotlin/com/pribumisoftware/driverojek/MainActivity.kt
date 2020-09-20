package com.pribumisoftware.driverojek

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.content.SharedPreferences;
import android.content.Context

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import androidx.core.content.pm.PackageInfoCompat.getLongVersionCode 

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
 

class MainActivity: FlutterActivity() {
    //private var mPendingIntent: PendingIntent? = null
  lateinit var flutterEngine1 : FlutterEngine
  var language: String ="Java"  
  val sharedData:HashMap<String,String> = HashMap<String,String>() 

  lateinit var sharedPref: SharedPreferences


  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        Log.wtf("TAG", "configureFlutterEngine==============================")
     
        val intent1 = intent 

		val timing = intent1.getStringExtra("timing")  ?: "" 
		val order = intent1.getStringExtra("order")  ?: ""     
		val body = intent.getStringExtra("body") ?: "" 
		val title = intent1.getStringExtra("title")  ?: "" 
		val message = intent.getStringExtra("message")?: ""
		val data_json = intent.getStringExtra("data_json")?: ""
		val category_order = intent.getStringExtra("category_order")?: ""

           
          
		sharedData.put("timing" ,timing )  
		sharedData.put("order" ,order ) 
		sharedData.put("body" ,body ) 
		sharedData.put("title" ,title )
		sharedData.put("message" ,message )  
		sharedData.put("data_json" ,data_json )   
		sharedData.put("category_order" ,category_order )   
		//sharedData.put("click_action", "FLUTTER_NOTIFICATION_CLICK" )   

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.channel.shared.data").setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
               if (call.method == "getSharedData") { 
                  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ada_pesan_masuk").invokeMethod("gcm_masuk",sharedData);
                  
                  result.success(sharedData)
                  sharedData.clear()   
                }else if (call.method == "getAll") { 
                  
                    val pm = applicationContext.packageManager
                    val info = pm.getPackageInfo(applicationContext.packageName, 0)

                    val map = HashMap<String, String>()
                    map["appName"] = info.applicationInfo.loadLabel(pm).toString()
                    map["packageName"] = applicationContext.packageName
                    map["version"] = info.versionName
                   // map["buildNumber"] = getLongVersionCode(info).toString()
                    result.success(map);
                    //sharedData.clear()   
                }else if (call.method == "Resume") { 
                    result.success("Resume")
                }else{
                     result.notImplemented()
                }
        } 
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "channel.keluar").setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
                if (call.method == "Logout") { 
                   MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "platform_keluar").invokeMethod("Logout","Logout");
                    result.success("Logout")
                } else{
                     result.notImplemented()
                }
        }   
    }
 
  override fun onNewIntent(intent : Intent){
        super.onNewIntent(intent);
          setIntent(intent)  
            
       val startingIntent : Intent? = intent
        if(startingIntent?.extras != null){  
           
            val timing = intent.getStringExtra("timing") ?: ""
             val order = intent.getStringExtra("order") ?: ""
            val body = intent.getStringExtra("body") ?: ""
            val title = intent.getStringExtra("title")?: ""
            val message = intent.getStringExtra("message")?: ""
		         val category_order = intent.getStringExtra("category_order")?: ""
		        val data_json = intent.getStringExtra("data_json")?: ""

           
            sharedData.put("timing" ,timing )
            sharedData.put("order" ,order) 
            sharedData.put("body" ,body ) 
            sharedData.put("title" ,title)
            sharedData.put("message" ,message )  
             sharedData.put("category_order" ,category_order)    
             sharedData.put("data_json",data_json )  

             // sharedData.put("click_action", "FLUTTER_NOTIFICATION_CLICK" 
            
               
          
        //flutterEngine1 = FlutterEngine(this) 
        //MethodChannel(flutterEngine1.dartExecutor.binaryMessenger, "app.channel.shared.data").invokeMethod("onSharedIntent================","ffffffffffff");
        } else{
          sharedData.put("value","onNewIntent++++++++++++++++++++++++++++++++" )  
        Log.wtf("onNewIntent", "onNewIntent++++++++++++++++++++++++++++++++")  
        }   
       //sharedData.put("onNewIntent" , "3000") ;
    }
    
    
    
     
    
}
