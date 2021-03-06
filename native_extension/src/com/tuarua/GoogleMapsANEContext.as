package com.tuarua {
import com.tuarua.googlemaps.Coordinate;
import com.tuarua.googlemaps.GoogleMapsEvent;
import com.tuarua.googlemaps.Marker;
import com.tuarua.googlemaps.permissions.PermissionEvent;
import com.tuarua.location.Address;
import com.tuarua.location.LocationEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.utils.Dictionary;

public class GoogleMapsANEContext {
    internal static const NAME:String = "GoogleMapsANE";
    internal static const TRACE:String = "TRACE";
    private static var _context:ExtensionContext;
    private static var _isDisposed:Boolean;
    private static var argsAsJSON:Object;
    public static var markers:Dictionary = new Dictionary();
    public static var overlays:Dictionary = new Dictionary();
    public static var circles:Dictionary = new Dictionary();
    public static var polylines:Dictionary = new Dictionary();
    public static var polygons:Dictionary = new Dictionary();

    public function GoogleMapsANEContext() {
    }

    public static function get context():ExtensionContext {
        if (_context == null) {
            try {
                _context = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
                if (_context == null) {
                    throw new Error("ANE " + NAME + " not created properly.  Future calls will fail.");
                }
                _context.addEventListener(StatusEvent.STATUS, gotEvent);
                _isDisposed = false;
            } catch (e:Error) {
                trace("[" + NAME + "] ANE not loaded properly.  Future calls will fail.");
            }
        }
        return _context;
    }

    private static function gotEvent(event:StatusEvent):void {
        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;
            case GoogleMapsEvent.DID_TAP_AT:
            case GoogleMapsEvent.DID_LONG_PRESS_AT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var coordinate:Coordinate = new Coordinate(argsAsJSON.latitude, argsAsJSON.longitude);
                    GoogleMapsANE.mapView.dispatchEvent(new GoogleMapsEvent(event.level, coordinate));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case GoogleMapsEvent.DID_TAP_MARKER:
            case GoogleMapsEvent.DID_BEGIN_DRAGGING:
            case GoogleMapsEvent.DID_DRAG:
            case GoogleMapsEvent.DID_TAP_INFO_WINDOW:
            case GoogleMapsEvent.DID_TAP_GROUND_OVERLAY:
            case GoogleMapsEvent.DID_TAP_POLYLINE:
            case GoogleMapsEvent.DID_TAP_POLYGON:
            case GoogleMapsEvent.DID_CLOSE_INFO_WINDOW:
            case GoogleMapsEvent.DID_LONG_PRESS_INFO_WINDOW:
            case GoogleMapsEvent.ON_READY:
            case GoogleMapsEvent.ON_LOADED:
            case GoogleMapsEvent.ON_CAMERA_IDLE:
            case GoogleMapsEvent.ON_BITMAP_READY:
                GoogleMapsANE.mapView.dispatchEvent(new GoogleMapsEvent(event.level, event.code));
                break;
            case GoogleMapsEvent.DID_END_DRAGGING:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var id:String = argsAsJSON.id;
                    var latitude:Number = argsAsJSON.latitude;
                    var longitude:Number = argsAsJSON.longitude;
                    var marker:Marker = markers[id] as Marker;
                    marker.coordinate.latitude = latitude;
                    marker.coordinate.longitude = longitude;
                    GoogleMapsANE.mapView.dispatchEvent(new GoogleMapsEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case GoogleMapsEvent.ON_CAMERA_MOVE:
            case GoogleMapsEvent.ON_CAMERA_MOVE_STARTED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    GoogleMapsANE.mapView.dispatchEvent(new GoogleMapsEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case LocationEvent.LOCATION_UPDATED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    GoogleMapsANE.mapView.dispatchEvent(new LocationEvent(event.level,
                            new Coordinate(argsAsJSON.latitude, argsAsJSON.longitude)));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case LocationEvent.ON_ADDRESS_LOOKUP:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    GoogleMapsANE.mapView.dispatchEvent(new LocationEvent(event.level,
                            new Coordinate(argsAsJSON.latitude, argsAsJSON.longitude),
                            new Address(
                                    argsAsJSON.formattedAddress,
                                    argsAsJSON.name,
                                    argsAsJSON.street,
                                    argsAsJSON.city,
                                    argsAsJSON.zip,
                                    argsAsJSON.country
                            )));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case LocationEvent.ON_ADDRESS_LOOKUP_ERROR:
                GoogleMapsANE.mapView.dispatchEvent(new LocationEvent(event.level, null, null, event.code));
                break;
            case PermissionEvent.ON_PERMISSION_STATUS:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    GoogleMapsANE.mapView.dispatchEvent(new PermissionEvent(event.level, argsAsJSON));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
        }
    }

    public static function dispose():void {
        if (!_context) {
            return;
        }
        _isDisposed = true;
        trace("[" + NAME + "] Unloading ANE...");
        _context.removeEventListener(StatusEvent.STATUS, gotEvent);
        _context.dispose();
        _context = null;
    }

    public static function get isDisposed():Boolean {
        return _isDisposed;
    }
}
}
