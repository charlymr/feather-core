//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 04. 18..
//

open class FeatherFormContext<T: FeatherModel>: FormComponent {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case nav
        case model
        case form
        case metadata
        case breadcrumb = "bc"
    }
    
    private var modelInfo: ModelInfo?

    open var form: Form
    open var model: T?
    open var nav: [Link]
    open var metadata: Metadata?
    open var breadcrumb: [Link]

    public init(form: Form = .init(), model: T? = nil, nav: [Link] = [], breadcrumb: [Link] = []) {
        self.form = form
        self.model = model
        self.nav = nav
        self.breadcrumb = breadcrumb
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nav, forKey: .nav)
        try container.encode(form, forKey: .form)
        try container.encodeIfPresent(modelInfo, forKey: .model)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encode(breadcrumb, forKey: .breadcrumb)
    }

    // MARK: - form component
        
    open func load(req: Request) -> EventLoopFuture<Void> {
        modelInfo = T.info(req)
        return form.load(req: req)
    }
    
    open func process(req: Request) -> EventLoopFuture<Void> {
        form.process(req: req)
    }
    
    open func validate(req: Request) -> EventLoopFuture<Bool> {
        form.validate(req: req)
    }
    
    open func write(req: Request) -> EventLoopFuture<Void> {
        form.write(req: req)
    }
    
    open func save(req: Request) -> EventLoopFuture<Void> {
        form.save(req: req)
    }
    
    open func read(req: Request) -> EventLoopFuture<Void> {
        form.read(req: req)
    }
}
