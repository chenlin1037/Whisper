import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "airplane" asset catalog image resource.
    static let airplane = DeveloperToolsSupport.ImageResource(name: "airplane", bundle: resourceBundle)

    /// The "airport" asset catalog image resource.
    static let airport = DeveloperToolsSupport.ImageResource(name: "airport", bundle: resourceBundle)

    /// The "ambulance-siren" asset catalog image resource.
    static let ambulanceSiren = DeveloperToolsSupport.ImageResource(name: "ambulance-siren", bundle: resourceBundle)

    /// The "aundry-room" asset catalog image resource.
    static let aundryRoom = DeveloperToolsSupport.ImageResource(name: "aundry-room", bundle: resourceBundle)

    /// The "beehive" asset catalog image resource.
    static let beehive = DeveloperToolsSupport.ImageResource(name: "beehive", bundle: resourceBundle)

    /// The "birds" asset catalog image resource.
    static let birds = DeveloperToolsSupport.ImageResource(name: "birds", bundle: resourceBundle)

    /// The "bubbles" asset catalog image resource.
    static let bubbles = DeveloperToolsSupport.ImageResource(name: "bubbles", bundle: resourceBundle)

    /// The "busy-street" asset catalog image resource.
    static let busyStreet = DeveloperToolsSupport.ImageResource(name: "busy-street", bundle: resourceBundle)

    /// The "cafe" asset catalog image resource.
    static let cafe = DeveloperToolsSupport.ImageResource(name: "cafe", bundle: resourceBundle)

    /// The "campfire" asset catalog image resource.
    static let campfire = DeveloperToolsSupport.ImageResource(name: "campfire", bundle: resourceBundle)

    /// The "carousel" asset catalog image resource.
    static let carousel = DeveloperToolsSupport.ImageResource(name: "carousel", bundle: resourceBundle)

    /// The "cat-purring" asset catalog image resource.
    static let catPurring = DeveloperToolsSupport.ImageResource(name: "cat-purring", bundle: resourceBundle)

    /// The "ceiling-fan" asset catalog image resource.
    static let ceilingFan = DeveloperToolsSupport.ImageResource(name: "ceiling-fan", bundle: resourceBundle)

    /// The "chickens" asset catalog image resource.
    static let chickens = DeveloperToolsSupport.ImageResource(name: "chickens", bundle: resourceBundle)

    /// The "church" asset catalog image resource.
    static let church = DeveloperToolsSupport.ImageResource(name: "church", bundle: resourceBundle)

    /// The "clock" asset catalog image resource.
    static let clock = DeveloperToolsSupport.ImageResource(name: "clock", bundle: resourceBundle)

    /// The "cows" asset catalog image resource.
    static let cows = DeveloperToolsSupport.ImageResource(name: "cows", bundle: resourceBundle)

    /// The "crickets" asset catalog image resource.
    static let crickets = DeveloperToolsSupport.ImageResource(name: "crickets", bundle: resourceBundle)

    /// The "crowd" asset catalog image resource.
    static let crowd = DeveloperToolsSupport.ImageResource(name: "crowd", bundle: resourceBundle)

    /// The "crowded-bar" asset catalog image resource.
    static let crowdedBar = DeveloperToolsSupport.ImageResource(name: "crowded-bar", bundle: resourceBundle)

    /// The "crows" asset catalog image resource.
    static let crows = DeveloperToolsSupport.ImageResource(name: "crows", bundle: resourceBundle)

    /// The "dog-barking" asset catalog image resource.
    static let dogBarking = DeveloperToolsSupport.ImageResource(name: "dog-barking", bundle: resourceBundle)

    /// The "droplets" asset catalog image resource.
    static let droplets = DeveloperToolsSupport.ImageResource(name: "droplets", bundle: resourceBundle)

    /// The "dryer" asset catalog image resource.
    static let dryer = DeveloperToolsSupport.ImageResource(name: "dryer", bundle: resourceBundle)

    /// The "fireworks" asset catalog image resource.
    static let fireworks = DeveloperToolsSupport.ImageResource(name: "fireworks", bundle: resourceBundle)

    /// The "frog" asset catalog image resource.
    static let frog = DeveloperToolsSupport.ImageResource(name: "frog", bundle: resourceBundle)

    /// The "fryer" asset catalog image resource.
    static let fryer = DeveloperToolsSupport.ImageResource(name: "fryer", bundle: resourceBundle)

    /// The "heavy-rain" asset catalog image resource.
    static let heavyRain = DeveloperToolsSupport.ImageResource(name: "heavy-rain", bundle: resourceBundle)

    /// The "highway" asset catalog image resource.
    static let highway = DeveloperToolsSupport.ImageResource(name: "highway", bundle: resourceBundle)

    /// The "horse-galopp" asset catalog image resource.
    static let horseGalopp = DeveloperToolsSupport.ImageResource(name: "horse-galopp", bundle: resourceBundle)

    /// The "howling-wind" asset catalog image resource.
    static let howlingWind = DeveloperToolsSupport.ImageResource(name: "howling-wind", bundle: resourceBundle)

    /// The "inside-a-train" asset catalog image resource.
    static let insideATrain = DeveloperToolsSupport.ImageResource(name: "inside-a-train", bundle: resourceBundle)

    /// The "jungle" asset catalog image resource.
    static let jungle = DeveloperToolsSupport.ImageResource(name: "jungle", bundle: resourceBundle)

    /// The "keyboard" asset catalog image resource.
    static let keyboard = DeveloperToolsSupport.ImageResource(name: "keyboard", bundle: resourceBundle)

    /// The "laboratory" asset catalog image resource.
    static let laboratory = DeveloperToolsSupport.ImageResource(name: "laboratory", bundle: resourceBundle)

    /// The "library" asset catalog image resource.
    static let library = DeveloperToolsSupport.ImageResource(name: "library", bundle: resourceBundle)

    /// The "light-rain" asset catalog image resource.
    static let lightRain = DeveloperToolsSupport.ImageResource(name: "light-rain", bundle: resourceBundle)

    /// The "morse-code" asset catalog image resource.
    static let morseCode = DeveloperToolsSupport.ImageResource(name: "morse-code", bundle: resourceBundle)

    /// The "night-village" asset catalog image resource.
    static let nightVillage = DeveloperToolsSupport.ImageResource(name: "night-village", bundle: resourceBundle)

    /// The "office" asset catalog image resource.
    static let office = DeveloperToolsSupport.ImageResource(name: "office", bundle: resourceBundle)

    /// The "owl" asset catalog image resource.
    static let owl = DeveloperToolsSupport.ImageResource(name: "owl", bundle: resourceBundle)

    /// The "paper" asset catalog image resource.
    static let paper = DeveloperToolsSupport.ImageResource(name: "paper", bundle: resourceBundle)

    /// The "rain-on-car-roof" asset catalog image resource.
    static let rainOnCarRoof = DeveloperToolsSupport.ImageResource(name: "rain-on-car-roof", bundle: resourceBundle)

    /// The "rain-on-leaves" asset catalog image resource.
    static let rainOnLeaves = DeveloperToolsSupport.ImageResource(name: "rain-on-leaves", bundle: resourceBundle)

    /// The "rain-on-tent" asset catalog image resource.
    static let rainOnTent = DeveloperToolsSupport.ImageResource(name: "rain-on-tent", bundle: resourceBundle)

    /// The "rain-on-umbrella" asset catalog image resource.
    static let rainOnUmbrella = DeveloperToolsSupport.ImageResource(name: "rain-on-umbrella", bundle: resourceBundle)

    /// The "rain-on-window" asset catalog image resource.
    static let rainOnWindow = DeveloperToolsSupport.ImageResource(name: "rain-on-window", bundle: resourceBundle)

    /// The "restaurant" asset catalog image resource.
    static let restaurant = DeveloperToolsSupport.ImageResource(name: "restaurant", bundle: resourceBundle)

    /// The "river" asset catalog image resource.
    static let river = DeveloperToolsSupport.ImageResource(name: "river", bundle: resourceBundle)

    /// The "road" asset catalog image resource.
    static let road = DeveloperToolsSupport.ImageResource(name: "road", bundle: resourceBundle)

    /// The "rowing-boat" asset catalog image resource.
    static let rowingBoat = DeveloperToolsSupport.ImageResource(name: "rowing-boat", bundle: resourceBundle)

    /// The "sailboat" asset catalog image resource.
    static let sailboat = DeveloperToolsSupport.ImageResource(name: "sailboat", bundle: resourceBundle)

    /// The "seagulls" asset catalog image resource.
    static let seagulls = DeveloperToolsSupport.ImageResource(name: "seagulls", bundle: resourceBundle)

    /// The "sheep" asset catalog image resource.
    static let sheep = DeveloperToolsSupport.ImageResource(name: "sheep", bundle: resourceBundle)

    /// The "singing-bowl" asset catalog image resource.
    static let singingBowl = DeveloperToolsSupport.ImageResource(name: "singing-bowl", bundle: resourceBundle)

    /// The "slide-projector" asset catalog image resource.
    static let slideProjector = DeveloperToolsSupport.ImageResource(name: "slide-projector", bundle: resourceBundle)

    /// The "submarine" asset catalog image resource.
    static let submarine = DeveloperToolsSupport.ImageResource(name: "submarine", bundle: resourceBundle)

    /// The "subway-station" asset catalog image resource.
    static let subwayStation = DeveloperToolsSupport.ImageResource(name: "subway-station", bundle: resourceBundle)

    /// The "supermarket" asset catalog image resource.
    static let supermarket = DeveloperToolsSupport.ImageResource(name: "supermarket", bundle: resourceBundle)

    /// The "thunder" asset catalog image resource.
    static let thunder = DeveloperToolsSupport.ImageResource(name: "thunder", bundle: resourceBundle)

    /// The "traffic" asset catalog image resource.
    static let traffic = DeveloperToolsSupport.ImageResource(name: "traffic", bundle: resourceBundle)

    /// The "typewriter" asset catalog image resource.
    static let typewriter = DeveloperToolsSupport.ImageResource(name: "typewriter", bundle: resourceBundle)

    /// The "underwater" asset catalog image resource.
    static let underwater = DeveloperToolsSupport.ImageResource(name: "underwater", bundle: resourceBundle)

    /// The "vinyl-effect" asset catalog image resource.
    static let vinylEffect = DeveloperToolsSupport.ImageResource(name: "vinyl-effect", bundle: resourceBundle)

    /// The "walk-in-snow" asset catalog image resource.
    static let walkInSnow = DeveloperToolsSupport.ImageResource(name: "walk-in-snow", bundle: resourceBundle)

    /// The "walk-on-gravel" asset catalog image resource.
    static let walkOnGravel = DeveloperToolsSupport.ImageResource(name: "walk-on-gravel", bundle: resourceBundle)

    /// The "walk-on-leaves" asset catalog image resource.
    static let walkOnLeaves = DeveloperToolsSupport.ImageResource(name: "walk-on-leaves", bundle: resourceBundle)

    /// The "washing-machine" asset catalog image resource.
    static let washingMachine = DeveloperToolsSupport.ImageResource(name: "washing-machine", bundle: resourceBundle)

    /// The "waterfall" asset catalog image resource.
    static let waterfall = DeveloperToolsSupport.ImageResource(name: "waterfall", bundle: resourceBundle)

    /// The "waves" asset catalog image resource.
    static let waves = DeveloperToolsSupport.ImageResource(name: "waves", bundle: resourceBundle)

    /// The "whale" asset catalog image resource.
    static let whale = DeveloperToolsSupport.ImageResource(name: "whale", bundle: resourceBundle)

    /// The "wind" asset catalog image resource.
    static let wind = DeveloperToolsSupport.ImageResource(name: "wind", bundle: resourceBundle)

    /// The "wind-chimes" asset catalog image resource.
    static let windChimes = DeveloperToolsSupport.ImageResource(name: "wind-chimes", bundle: resourceBundle)

    /// The "windshield-wipers" asset catalog image resource.
    static let windshieldWipers = DeveloperToolsSupport.ImageResource(name: "windshield-wipers", bundle: resourceBundle)

    /// The "wolf" asset catalog image resource.
    static let wolf = DeveloperToolsSupport.ImageResource(name: "wolf", bundle: resourceBundle)

    /// The "woodpecker" asset catalog image resource.
    static let woodpecker = DeveloperToolsSupport.ImageResource(name: "woodpecker", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "airplane" asset catalog image.
    static var airplane: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .airplane)
#else
        .init()
#endif
    }

    /// The "airport" asset catalog image.
    static var airport: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .airport)
#else
        .init()
#endif
    }

    /// The "ambulance-siren" asset catalog image.
    static var ambulanceSiren: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ambulanceSiren)
#else
        .init()
#endif
    }

    /// The "aundry-room" asset catalog image.
    static var aundryRoom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aundryRoom)
#else
        .init()
#endif
    }

    /// The "beehive" asset catalog image.
    static var beehive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .beehive)
#else
        .init()
#endif
    }

    /// The "birds" asset catalog image.
    static var birds: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .birds)
#else
        .init()
#endif
    }

    /// The "bubbles" asset catalog image.
    static var bubbles: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bubbles)
#else
        .init()
#endif
    }

    /// The "busy-street" asset catalog image.
    static var busyStreet: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .busyStreet)
#else
        .init()
#endif
    }

    /// The "cafe" asset catalog image.
    static var cafe: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cafe)
#else
        .init()
#endif
    }

    /// The "campfire" asset catalog image.
    static var campfire: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .campfire)
#else
        .init()
#endif
    }

    /// The "carousel" asset catalog image.
    static var carousel: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .carousel)
#else
        .init()
#endif
    }

    /// The "cat-purring" asset catalog image.
    static var catPurring: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .catPurring)
#else
        .init()
#endif
    }

    /// The "ceiling-fan" asset catalog image.
    static var ceilingFan: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ceilingFan)
#else
        .init()
#endif
    }

    /// The "chickens" asset catalog image.
    static var chickens: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .chickens)
#else
        .init()
#endif
    }

    /// The "church" asset catalog image.
    static var church: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .church)
#else
        .init()
#endif
    }

    /// The "clock" asset catalog image.
    static var clock: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .clock)
#else
        .init()
#endif
    }

    /// The "cows" asset catalog image.
    static var cows: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cows)
#else
        .init()
#endif
    }

    /// The "crickets" asset catalog image.
    static var crickets: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .crickets)
#else
        .init()
#endif
    }

    /// The "crowd" asset catalog image.
    static var crowd: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .crowd)
#else
        .init()
#endif
    }

    /// The "crowded-bar" asset catalog image.
    static var crowdedBar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .crowdedBar)
#else
        .init()
#endif
    }

    /// The "crows" asset catalog image.
    static var crows: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .crows)
#else
        .init()
#endif
    }

    /// The "dog-barking" asset catalog image.
    static var dogBarking: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dogBarking)
#else
        .init()
#endif
    }

    /// The "droplets" asset catalog image.
    static var droplets: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .droplets)
#else
        .init()
#endif
    }

    /// The "dryer" asset catalog image.
    static var dryer: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dryer)
#else
        .init()
#endif
    }

    /// The "fireworks" asset catalog image.
    static var fireworks: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fireworks)
#else
        .init()
#endif
    }

    /// The "frog" asset catalog image.
    static var frog: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .frog)
#else
        .init()
#endif
    }

    /// The "fryer" asset catalog image.
    static var fryer: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fryer)
#else
        .init()
#endif
    }

    /// The "heavy-rain" asset catalog image.
    static var heavyRain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heavyRain)
#else
        .init()
#endif
    }

    /// The "highway" asset catalog image.
    static var highway: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .highway)
#else
        .init()
#endif
    }

    /// The "horse-galopp" asset catalog image.
    static var horseGalopp: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .horseGalopp)
#else
        .init()
#endif
    }

    /// The "howling-wind" asset catalog image.
    static var howlingWind: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .howlingWind)
#else
        .init()
#endif
    }

    /// The "inside-a-train" asset catalog image.
    static var insideATrain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .insideATrain)
#else
        .init()
#endif
    }

    /// The "jungle" asset catalog image.
    static var jungle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jungle)
#else
        .init()
#endif
    }

    /// The "keyboard" asset catalog image.
    static var keyboard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .keyboard)
#else
        .init()
#endif
    }

    /// The "laboratory" asset catalog image.
    static var laboratory: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .laboratory)
#else
        .init()
#endif
    }

    /// The "library" asset catalog image.
    static var library: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .library)
#else
        .init()
#endif
    }

    /// The "light-rain" asset catalog image.
    static var lightRain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lightRain)
#else
        .init()
#endif
    }

    /// The "morse-code" asset catalog image.
    static var morseCode: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .morseCode)
#else
        .init()
#endif
    }

    /// The "night-village" asset catalog image.
    static var nightVillage: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .nightVillage)
#else
        .init()
#endif
    }

    /// The "office" asset catalog image.
    static var office: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .office)
#else
        .init()
#endif
    }

    /// The "owl" asset catalog image.
    static var owl: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .owl)
#else
        .init()
#endif
    }

    /// The "paper" asset catalog image.
    static var paper: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .paper)
#else
        .init()
#endif
    }

    /// The "rain-on-car-roof" asset catalog image.
    static var rainOnCarRoof: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rainOnCarRoof)
#else
        .init()
#endif
    }

    /// The "rain-on-leaves" asset catalog image.
    static var rainOnLeaves: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rainOnLeaves)
#else
        .init()
#endif
    }

    /// The "rain-on-tent" asset catalog image.
    static var rainOnTent: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rainOnTent)
#else
        .init()
#endif
    }

    /// The "rain-on-umbrella" asset catalog image.
    static var rainOnUmbrella: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rainOnUmbrella)
#else
        .init()
#endif
    }

    /// The "rain-on-window" asset catalog image.
    static var rainOnWindow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rainOnWindow)
#else
        .init()
#endif
    }

    /// The "restaurant" asset catalog image.
    static var restaurant: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .restaurant)
#else
        .init()
#endif
    }

    /// The "river" asset catalog image.
    static var river: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .river)
#else
        .init()
#endif
    }

    /// The "road" asset catalog image.
    static var road: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .road)
#else
        .init()
#endif
    }

    /// The "rowing-boat" asset catalog image.
    static var rowingBoat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rowingBoat)
#else
        .init()
#endif
    }

    /// The "sailboat" asset catalog image.
    static var sailboat: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sailboat)
#else
        .init()
#endif
    }

    /// The "seagulls" asset catalog image.
    static var seagulls: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .seagulls)
#else
        .init()
#endif
    }

    /// The "sheep" asset catalog image.
    static var sheep: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sheep)
#else
        .init()
#endif
    }

    /// The "singing-bowl" asset catalog image.
    static var singingBowl: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .singingBowl)
#else
        .init()
#endif
    }

    /// The "slide-projector" asset catalog image.
    static var slideProjector: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .slideProjector)
#else
        .init()
#endif
    }

    /// The "submarine" asset catalog image.
    static var submarine: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .submarine)
#else
        .init()
#endif
    }

    /// The "subway-station" asset catalog image.
    static var subwayStation: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .subwayStation)
#else
        .init()
#endif
    }

    /// The "supermarket" asset catalog image.
    static var supermarket: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .supermarket)
#else
        .init()
#endif
    }

    /// The "thunder" asset catalog image.
    static var thunder: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .thunder)
#else
        .init()
#endif
    }

    /// The "traffic" asset catalog image.
    static var traffic: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .traffic)
#else
        .init()
#endif
    }

    /// The "typewriter" asset catalog image.
    static var typewriter: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .typewriter)
#else
        .init()
#endif
    }

    /// The "underwater" asset catalog image.
    static var underwater: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .underwater)
#else
        .init()
#endif
    }

    /// The "vinyl-effect" asset catalog image.
    static var vinylEffect: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .vinylEffect)
#else
        .init()
#endif
    }

    /// The "walk-in-snow" asset catalog image.
    static var walkInSnow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .walkInSnow)
#else
        .init()
#endif
    }

    /// The "walk-on-gravel" asset catalog image.
    static var walkOnGravel: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .walkOnGravel)
#else
        .init()
#endif
    }

    /// The "walk-on-leaves" asset catalog image.
    static var walkOnLeaves: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .walkOnLeaves)
#else
        .init()
#endif
    }

    /// The "washing-machine" asset catalog image.
    static var washingMachine: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .washingMachine)
#else
        .init()
#endif
    }

    /// The "waterfall" asset catalog image.
    static var waterfall: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .waterfall)
#else
        .init()
#endif
    }

    /// The "waves" asset catalog image.
    static var waves: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .waves)
#else
        .init()
#endif
    }

    /// The "whale" asset catalog image.
    static var whale: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .whale)
#else
        .init()
#endif
    }

    /// The "wind" asset catalog image.
    static var wind: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .wind)
#else
        .init()
#endif
    }

    /// The "wind-chimes" asset catalog image.
    static var windChimes: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .windChimes)
#else
        .init()
#endif
    }

    /// The "windshield-wipers" asset catalog image.
    static var windshieldWipers: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .windshieldWipers)
#else
        .init()
#endif
    }

    /// The "wolf" asset catalog image.
    static var wolf: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .wolf)
#else
        .init()
#endif
    }

    /// The "woodpecker" asset catalog image.
    static var woodpecker: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .woodpecker)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "airplane" asset catalog image.
    static var airplane: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .airplane)
#else
        .init()
#endif
    }

    /// The "airport" asset catalog image.
    static var airport: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .airport)
#else
        .init()
#endif
    }

    /// The "ambulance-siren" asset catalog image.
    static var ambulanceSiren: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ambulanceSiren)
#else
        .init()
#endif
    }

    /// The "aundry-room" asset catalog image.
    static var aundryRoom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aundryRoom)
#else
        .init()
#endif
    }

    /// The "beehive" asset catalog image.
    static var beehive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .beehive)
#else
        .init()
#endif
    }

    /// The "birds" asset catalog image.
    static var birds: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .birds)
#else
        .init()
#endif
    }

    /// The "bubbles" asset catalog image.
    static var bubbles: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bubbles)
#else
        .init()
#endif
    }

    /// The "busy-street" asset catalog image.
    static var busyStreet: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .busyStreet)
#else
        .init()
#endif
    }

    /// The "cafe" asset catalog image.
    static var cafe: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cafe)
#else
        .init()
#endif
    }

    /// The "campfire" asset catalog image.
    static var campfire: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .campfire)
#else
        .init()
#endif
    }

    /// The "carousel" asset catalog image.
    static var carousel: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .carousel)
#else
        .init()
#endif
    }

    /// The "cat-purring" asset catalog image.
    static var catPurring: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .catPurring)
#else
        .init()
#endif
    }

    /// The "ceiling-fan" asset catalog image.
    static var ceilingFan: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ceilingFan)
#else
        .init()
#endif
    }

    /// The "chickens" asset catalog image.
    static var chickens: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .chickens)
#else
        .init()
#endif
    }

    /// The "church" asset catalog image.
    static var church: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .church)
#else
        .init()
#endif
    }

    /// The "clock" asset catalog image.
    static var clock: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .clock)
#else
        .init()
#endif
    }

    /// The "cows" asset catalog image.
    static var cows: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cows)
#else
        .init()
#endif
    }

    /// The "crickets" asset catalog image.
    static var crickets: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .crickets)
#else
        .init()
#endif
    }

    /// The "crowd" asset catalog image.
    static var crowd: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .crowd)
#else
        .init()
#endif
    }

    /// The "crowded-bar" asset catalog image.
    static var crowdedBar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .crowdedBar)
#else
        .init()
#endif
    }

    /// The "crows" asset catalog image.
    static var crows: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .crows)
#else
        .init()
#endif
    }

    /// The "dog-barking" asset catalog image.
    static var dogBarking: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dogBarking)
#else
        .init()
#endif
    }

    /// The "droplets" asset catalog image.
    static var droplets: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .droplets)
#else
        .init()
#endif
    }

    /// The "dryer" asset catalog image.
    static var dryer: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dryer)
#else
        .init()
#endif
    }

    /// The "fireworks" asset catalog image.
    static var fireworks: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fireworks)
#else
        .init()
#endif
    }

    /// The "frog" asset catalog image.
    static var frog: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .frog)
#else
        .init()
#endif
    }

    /// The "fryer" asset catalog image.
    static var fryer: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fryer)
#else
        .init()
#endif
    }

    /// The "heavy-rain" asset catalog image.
    static var heavyRain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heavyRain)
#else
        .init()
#endif
    }

    /// The "highway" asset catalog image.
    static var highway: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .highway)
#else
        .init()
#endif
    }

    /// The "horse-galopp" asset catalog image.
    static var horseGalopp: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .horseGalopp)
#else
        .init()
#endif
    }

    /// The "howling-wind" asset catalog image.
    static var howlingWind: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .howlingWind)
#else
        .init()
#endif
    }

    /// The "inside-a-train" asset catalog image.
    static var insideATrain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .insideATrain)
#else
        .init()
#endif
    }

    /// The "jungle" asset catalog image.
    static var jungle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jungle)
#else
        .init()
#endif
    }

    /// The "keyboard" asset catalog image.
    static var keyboard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .keyboard)
#else
        .init()
#endif
    }

    /// The "laboratory" asset catalog image.
    static var laboratory: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .laboratory)
#else
        .init()
#endif
    }

    /// The "library" asset catalog image.
    static var library: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .library)
#else
        .init()
#endif
    }

    /// The "light-rain" asset catalog image.
    static var lightRain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lightRain)
#else
        .init()
#endif
    }

    /// The "morse-code" asset catalog image.
    static var morseCode: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .morseCode)
#else
        .init()
#endif
    }

    /// The "night-village" asset catalog image.
    static var nightVillage: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .nightVillage)
#else
        .init()
#endif
    }

    /// The "office" asset catalog image.
    static var office: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .office)
#else
        .init()
#endif
    }

    /// The "owl" asset catalog image.
    static var owl: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .owl)
#else
        .init()
#endif
    }

    /// The "paper" asset catalog image.
    static var paper: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .paper)
#else
        .init()
#endif
    }

    /// The "rain-on-car-roof" asset catalog image.
    static var rainOnCarRoof: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rainOnCarRoof)
#else
        .init()
#endif
    }

    /// The "rain-on-leaves" asset catalog image.
    static var rainOnLeaves: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rainOnLeaves)
#else
        .init()
#endif
    }

    /// The "rain-on-tent" asset catalog image.
    static var rainOnTent: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rainOnTent)
#else
        .init()
#endif
    }

    /// The "rain-on-umbrella" asset catalog image.
    static var rainOnUmbrella: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rainOnUmbrella)
#else
        .init()
#endif
    }

    /// The "rain-on-window" asset catalog image.
    static var rainOnWindow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rainOnWindow)
#else
        .init()
#endif
    }

    /// The "restaurant" asset catalog image.
    static var restaurant: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .restaurant)
#else
        .init()
#endif
    }

    /// The "river" asset catalog image.
    static var river: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .river)
#else
        .init()
#endif
    }

    /// The "road" asset catalog image.
    static var road: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .road)
#else
        .init()
#endif
    }

    /// The "rowing-boat" asset catalog image.
    static var rowingBoat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rowingBoat)
#else
        .init()
#endif
    }

    /// The "sailboat" asset catalog image.
    static var sailboat: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sailboat)
#else
        .init()
#endif
    }

    /// The "seagulls" asset catalog image.
    static var seagulls: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .seagulls)
#else
        .init()
#endif
    }

    /// The "sheep" asset catalog image.
    static var sheep: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sheep)
#else
        .init()
#endif
    }

    /// The "singing-bowl" asset catalog image.
    static var singingBowl: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .singingBowl)
#else
        .init()
#endif
    }

    /// The "slide-projector" asset catalog image.
    static var slideProjector: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .slideProjector)
#else
        .init()
#endif
    }

    /// The "submarine" asset catalog image.
    static var submarine: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .submarine)
#else
        .init()
#endif
    }

    /// The "subway-station" asset catalog image.
    static var subwayStation: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .subwayStation)
#else
        .init()
#endif
    }

    /// The "supermarket" asset catalog image.
    static var supermarket: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .supermarket)
#else
        .init()
#endif
    }

    /// The "thunder" asset catalog image.
    static var thunder: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .thunder)
#else
        .init()
#endif
    }

    /// The "traffic" asset catalog image.
    static var traffic: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .traffic)
#else
        .init()
#endif
    }

    /// The "typewriter" asset catalog image.
    static var typewriter: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .typewriter)
#else
        .init()
#endif
    }

    /// The "underwater" asset catalog image.
    static var underwater: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .underwater)
#else
        .init()
#endif
    }

    /// The "vinyl-effect" asset catalog image.
    static var vinylEffect: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .vinylEffect)
#else
        .init()
#endif
    }

    /// The "walk-in-snow" asset catalog image.
    static var walkInSnow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .walkInSnow)
#else
        .init()
#endif
    }

    /// The "walk-on-gravel" asset catalog image.
    static var walkOnGravel: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .walkOnGravel)
#else
        .init()
#endif
    }

    /// The "walk-on-leaves" asset catalog image.
    static var walkOnLeaves: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .walkOnLeaves)
#else
        .init()
#endif
    }

    /// The "washing-machine" asset catalog image.
    static var washingMachine: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .washingMachine)
#else
        .init()
#endif
    }

    /// The "waterfall" asset catalog image.
    static var waterfall: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .waterfall)
#else
        .init()
#endif
    }

    /// The "waves" asset catalog image.
    static var waves: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .waves)
#else
        .init()
#endif
    }

    /// The "whale" asset catalog image.
    static var whale: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .whale)
#else
        .init()
#endif
    }

    /// The "wind" asset catalog image.
    static var wind: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .wind)
#else
        .init()
#endif
    }

    /// The "wind-chimes" asset catalog image.
    static var windChimes: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .windChimes)
#else
        .init()
#endif
    }

    /// The "windshield-wipers" asset catalog image.
    static var windshieldWipers: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .windshieldWipers)
#else
        .init()
#endif
    }

    /// The "wolf" asset catalog image.
    static var wolf: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .wolf)
#else
        .init()
#endif
    }

    /// The "woodpecker" asset catalog image.
    static var woodpecker: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .woodpecker)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

