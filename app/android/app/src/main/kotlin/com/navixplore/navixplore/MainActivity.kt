package com.navixplore.navixplore

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTile", NativeAdFactoryExample(this)
        )
    }
    override fun onDestroy() {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine!!,"listTile")
        super.onDestroy()
    }
}

class NativeAdFactoryExample(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView


        if(nativeAd.headline ==null){
            return adView;
        }
        // Set the headline.
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView?.text = nativeAd.headline

        //  Set the body
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        bodyView?.text = nativeAd.body

        // Set the call to action.
        val callToActionView = adView.findViewById<TextView>(R.id.ad_call_to_action)
        callToActionView?.text = nativeAd.callToAction

        // Set the media
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        adView.mediaView = mediaView


        //Set the Icon
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        adView.iconView= iconView
        val nativeAdIcon = nativeAd.icon
        if(nativeAdIcon !=null){
            iconView?.setImageDrawable(nativeAdIcon.drawable)
        }
        // Store the ad asset views.
        adView.bodyView = bodyView
        adView.headlineView = headlineView
        adView.callToActionView = callToActionView


        // This method tells the Google Mobile Ads SDK that you have finished populating the
        // ad view with this native ad. The SDK will then measure the ad and report its
        // size to the app.
        adView.setNativeAd(nativeAd)

        return adView
    }
}