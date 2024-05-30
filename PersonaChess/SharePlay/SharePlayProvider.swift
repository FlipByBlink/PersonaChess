import LinkPresentation

enum SharePlayProvider {
    static func registerGroupActivity() {
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(AppGroupActivity())
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return nil }
            let metadata = LPLinkMetadata()
            metadata.title = "Chess"
            metadata.imageProvider = NSItemProvider(object: UIImage(resource: .wholeIcon))
            return metadata
        }
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter {
                ($0.session.userInfo?["com.apple.SwiftUI.sceneID"] as? String) == "volume"
            }
            .first!
            .windows
            .first!
            .rootViewController!
            .activityItemsConfiguration = configuration
    }
}

/* ==== Ref: "Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer" ====
https://developer.apple.com/wwdc23/10087?time=866

/*
(Transcript English)
The way an app exposes the group activity is done through the same way as starting SharePlay via AirDrop.
In iOS 17, you can start SharePlay via AirDrop by having a SharePlay app open.
To fetch the group activity, the system goes through the UI responder chain of the scene that is being shown and tries to find a group activity that is specified in the activity items configuration of one of the responders.
That way you can just set the group activity on the activity items configuration of a view controller that is showing SharePlayable content, and it will get picked up automatically.
To configure the Activity Items configuration, you start by creating the activity that can be activated.
Next you'll create an item provider and register the group activity on it.
You then initialize the UIActivityItemsConfiguration with the item provider.
Finally, you'll need to make sure that the configuration exposes the right metadata, since that is what will be presented in the Share menu.
To do that, you can use the metadataProvider on UIActivityItemsConfiguration and provide an LPLinkMetadata object for the LinkPresentationMetadata key.
The title and image provider will be used in the Share menu.
All of this will also work if you use your own class that conforms to UIActivityItemsConfigurationReading.
*/

/*
(Transcript Japanese)
グループアクティビティの公開は AirDropでSharePlayを 始めるのと同じ方法で行います
iOS 17では SharePlayアプリを 開いておく事で AirDropでSharePlayが 始められるようになります
グループアクティビティをフェッチするのに システムは表示されているシーンの UIレスポンダチェーン内を探し そのうちの一つのレスポンダの アクティビティアイテム設定で 特定されているグループアクティビティを 見つけようとします
そうすると SharePlayコンテンツを 表示しているビューコントローラの アクティビティアイテム設定で グループアクティビティを設定できて それが自動的にピックアップされます
アクティビティアイテム設定を行うには まず 有効化できるアクティビティを 作ることから始めます
次に アイテムプロバイダを作成して そこに グループアクティビティを 登録します
それからアイテムプロバイダで UIActivityItemsConfigurationを 初期化します
最後は 設定が公開しているのが 正しいメタデータである事を 確認しましょう
それがShareメニューで表示されるからです
そのためには metadataProviderを UIActivityItemsConfigurationで使い LinkPresentationMetadataキーのために LPLinkMetadataオブジェクトを提供します
Shareメニューにはtitleと imageProviderが使われます
UIActivityItemsConfigurationReadingに 準拠する自分のクラスを使っても すべてこの通りに作業できます
*/

/*
// (Code)
let activity = ExploreActivity()
let itemProvider = NSItemProvider()
itemProvider.registerGroupActivity(activity)
let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
configuration.metadataProvider = { key in
    guard key == .linkPresentationMetadata else { return nil }
    let metadata = LPLinkMetadata()
    metadata.title = "Explore Together"
    metadata.imageProvider = NSItemProvider(object: UIImage(named: "explore-activity")!)
    return metadata
}
self.activityItemsConfiguration = configuration
*/

================================================================ */
