//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 04. 21..
//

final class FrontendModule: FeatherModule {

    static var moduleKey: String = "frontend"

    static var bundleUrl: URL? { moduleBundleUrl }

    func boot(_ app: Application) throws {
        /// database
        app.migrations.add(FrontendMigration_v1())
        app.databases.middleware.use(MetadataModelMiddleware<FrontendPageModel>())
        /// middlewares
        app.hooks.register(.webMiddlewares, use: webMiddlewaresHook)
        /// install
        app.hooks.register(.installModels, use: installModelsHook)
        app.hooks.register(.installPermissions, use: installPermissionsHook)
        app.hooks.register(.installVariables, use: installVariablesHook)
        /// admin menus
        app.hooks.register(.adminMenu, use: adminMenuHook)
        ///template
        app.hooks.register(.frontendCss, use: frontendCssHook)
//        app.hooks.register(.frontendCssInline, use: frontendCssInlineHook)
        /// routes
        try FrontendRouter().bootAndRegisterHooks(app)
        /// pages
        app.hooks.register(.response, use: responseHook)
        app.hooks.register("welcome-page", use: welcomePageHook)
    }
  
    // MARK: - hooks
    
    func frontendCssHook(args: HookArguments) -> [OrderedTemplateData] {
        [
            .init("frontend", order: 500),
        ]
    }

    func frontendCssInlineHook(args: HookArguments) -> [OrderedTemplateData] {
        [
            .init("main { background-color: red !important; }", order: 500),
        ]
    }
        
    func webMiddlewaresHook(args: HookArguments) -> [Middleware] {
        [
            FrontendTemplateScopeMiddleware(),
            FrontendSafePathMiddleware(),
        ]
    }
    
    func responseHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args.req
        return FrontendPageModel
            .queryJoinVisibleMetadata(path: req.url.path, on: req.db)
            .first()
            .flatMap { page -> EventLoopFuture<Response?> in
                guard let page = page else {
                    return req.eventLoop.future(nil)
                }
                /// if the content of a page has a page tag, then we respond with the corresponding page hook function
                let content = page.content.trimmingCharacters(in: .whitespacesAndNewlines)
                if content.hasPrefix("["), content.hasSuffix("-page]") {
                    let name = String(content.dropFirst().dropLast())
                    var args = HookArguments()
                    if let metadata = page.joinedMetadata {
                        args.metadata = metadata
                    }
                    if let future: EventLoopFuture<Response?> = req.invoke(name, args: args) {
                        return future
                    }
                }
                /// render the page with the filtered content
                return page.filter(content, req: req).flatMap {
                    var ctx = page.encodeToTemplateData().dictionary!
                    ctx["content"] = .string($0)
                    ctx["metadata"] = page.joinedMetadata?.encodeToTemplateData()
                    return req.tau.render(template: "Frontend/Page", context: .init(ctx)).encodeOptionalResponse(for: req)
                }
            }
    }
    
    /// renders the [home-page] content
    func welcomePageHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args.req
        
        return req.view.render("Frontend/Welcome", ["metadata": args.metadata]).encodeOptionalResponse(for: req)
    }

    func adminMenuHook(args: HookArguments) -> HookObjects.AdminMenu {
        .init(key: "frontend",
              item: .init(icon: "layout", link: Self.adminLink, priority: 100, permission: Self.permission(for: .custom("admin")).identifier),
              children: [
                .init(link: .init(label: "Settings", url: "/admin/frontend/settings/"), permission: Self.permission(for: .custom("admin")).identifier),
                .init(link: FrontendPageModel.adminLink, permission: FrontendPageModel.permission(for: .list).identifier),
                .init(link: FrontendMenuModel.adminLink, permission: FrontendMenuModel.permission(for: .list).identifier),
                .init(link: FrontendMetadataModel.adminLink, permission: FrontendMetadataModel.permission(for: .list).identifier),
              ])
    }
}
