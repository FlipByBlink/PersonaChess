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

/* ==== https://developer.apple.com/wwdc23/10087?time=866 ====
 グループアクティビティの公開は AirDropでSharePlayを 始めるのと同じ方法で行います iOS 17では SharePlayアプリを 開いておく事で AirDropでSharePlayが 始められるようになります グループアクティビティをフェッチするのに システムは表示されているシーンの UIレスポンダチェーン内を探し そのうちの一つのレスポンダの アクティビティアイテム設定で 特定されているグループアクティビティを 見つけようとします そうすると SharePlayコンテンツを 表示しているビューコントローラの アクティビティアイテム設定で グループアクティビティを設定できて それが自動的にピックアップされます アクティビティアイテム設定を行うには まず 有効化できるアクティビティを 作ることから始めます 次に アイテムプロバイダを作成して そこに グループアクティビティを 登録します それからアイテムプロバイダで UIActivityItemsConfigurationを 初期化します 最後は 設定が公開しているのが 正しいメタデータである事を 確認しましょう それがShareメニューで表示されるからです そのためには metadataProviderを UIActivityItemsConfigurationで使い LinkPresentationMetadataキーのために LPLinkMetadataオブジェクトを提供します Shareメニューにはtitleと imageProviderが使われます UIActivityItemsConfigurationReadingに 準拠する自分のクラスを使っても すべてこの通りに作業できます
 // Create the activity
 let activity = ExploreActivity()
 // Register the activity on the item provider
 let itemProvider = NSItemProvider()
 itemProvider.registerGroupActivity(activity)
 // Create the activity items configuration
 let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
 // Provide the metadata for the group activity
 configuration.metadataProvider = { key in
 guard key == .linkPresentationMetadata else { return nil }
 let metadata = LPLinkMetadata()
 metadata.title = "Explore Together"
 metadata.imageProvider = NSItemProvider(object: UIImage(named: "explore-activity")!)
 return metadata
 }
 self.activityItemsConfiguration = configuration
 ======== */
