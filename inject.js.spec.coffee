describe 'injector', () ->
    describe 'register', () ->
        test_type = null
        test_result = null
        beforeEach () ->
            test_type = () ->
            test_result =
                name: 'test type',
                type: test_type,
                dependencies: null,
                lifetime: 'transient'
        afterEach () ->
            injector.types = {};
            injector.providers = {};

        describe 'register', () ->
            it 'registers a provided type', () ->
                injector.register 'types', 'test type', ['test_dependency', test_type], 'singleton'
                test_result.dependencies = ['test_dependency']
                test_result.lifetime = 'singleton'
                expect(injector.types['test type']).toEqual test_result

            it 'sets empty dependencies when type has no dependencies', () ->
                injector.register 'types', 'test type', test_type, 'singleton'
                test_result.lifetime = 'singleton'
                expect(injector.types['test type']).toEqual test_result
            it 'throws an error when no name is passed', () ->
                expect(() -> injector.register('types', test_type)).toThrow 'Type must have a name'

            it 'throws an error when name is empty string', () ->
                expect(() -> injector.register('types', '', test_type)).toThrow 'Type must have a name'

            it 'throws an error when no type is passed', () ->
                expect(() -> injector.register('types', 'no type')).toThrow 'no type was passed'

            it 'throws an error when last item in type array isn`t a function', () ->
                expect(() -> injector.register('types', 'no type', ['test dependency'])).toThrow 'no type was passed'

            it 'throws an error when an invalid where is passed', () ->
                expect(() -> injector.register('invalid where', 'test type', test_type)).toThrow 'invalid destination "invalid where" provided. Valid destinations are types, providers, and main'

        describe 'registerType', () ->
            it 'registers a provided type', () ->
                injector.registerType 'test type', test_type, 'singleton'
                test_result.lifetime = 'singleton'
                expect(injector.types['test type']).toEqual test_result

            it 'defaults to transient lifetime', () ->
                injector.registerType 'test type', ['test_dependency', test_type]
                test_result.dependencies = ['test_dependency']
                expect(injector.types['test type']).toEqual test_result

            it 'throws an error when invalid lifetime is passed', () ->

                expect(() -> injector.registerType('test type', test_type , 'invalid lifetime')).toThrow 'invalid lifetime "invalid lifetime" provided. Valid lifetimes are singleton, transient, instance and parent'

        describe 'registerProvider', () ->
            beforeEach () ->
                delete test_result.lifetime

            it 'registers a provider', () ->
                injector.registerProvider 'test type', test_type
                expect(injector.providers['test type']).toEqual test_result

        describe 'register main', () ->
            it 'registers the main entry point', () ->
                injector.registerMain test_type
                test_result.name = 'main';
                delete test_result.lifetime;
                expect(injector.providers['main']).toEqual test_result

    describe 'instantiate', () ->
        beforeEach () ->
            injector.types =
                test:
                    name: 'test'
                    dependencies: null
                    type: class test_type
                        constructor: (@test_dependency) ->
                    lifetime: 'transient'
                test_dependency:
                    name: 'test_dependency'
                    dependencies: null
                    type: class test_dependency
                    lifetime: 'transient'
        it 'instantiates a given type', () ->
            test = injector.instantiate 'test'
            expect(test instanceof injector.types.test.type).toBeTruthy()

        it 'instantiates a given type`s dependencies', () ->
            injector.types.test.dependencies = ['test_dependency']
            test = injector.instantiate 'test'
            expect(test.test_dependency instanceof injector.types.test_dependency.type).toBeTruthy()


    describe 'inject', () ->
        test_provider_spy = null
        test_provider_dependency_stub = null
        beforeEach () ->
            test_provider_spy = sinon.spy()
            test_provider_dependency_stub = sinon.stub()
            test_provider_dependency_stub.returns('test')
            injector.types =
                test:
                    name: 'test'
                    dependencies: null
                    type: class test_type
                        constructor: (@test_dependency) ->
                    lifetime: 'transient'
                test_dependency:
                    name: 'test_dependency'
                    dependencies: null
                    type: class test_dependency
                    lifetime: 'transient'
            injector.providers =
                test_provider:
                    name: 'test_provider'
                    dependencies: null
                    type: test_provider_spy
                    lifetime: 'transient'
                test_provider_dependency:
                    name: 'test_provider_dependency'
                    dependencies: null
                    type: test_provider_dependency_stub
                    lifetime: 'transient'

        it 'creates a function that returns an instance of the given type', () ->
            test = injector.inject 'test'
            expect(test() instanceof injector.types.test.type).toBeTruthy()

        it 'instantiates a given type`s dependencies', () ->
            injector.types.test.dependencies = ['test_dependency']
            test = injector.inject 'test'
            expect(test().test_dependency instanceof injector.types.test_dependency.type).toBeTruthy()

        it 'creates a function that returns the given provider', () ->
            test = injector.inject 'test_provider'
            test()
            expect(test_provider_spy).toHaveBeenCalledOnce()

        it 'injects dependencies into given provider', () ->
            injector.providers.test_provider.dependencies = ['test_provider_dependency']
            test = injector.inject 'test_provider'
            test()
            expect(test_provider_dependency_stub).toHaveBeenCalledOnce()
            expect(test_provider_spy).toHaveBeenCalledWith('test')

    describe 'lifetime', () ->
        test_provider_spy = null
        test_provider_dependency_stub = null
        beforeEach () ->
            test_provider_spy = sinon.spy()
            test_provider_dependency_stub = sinon.stub()
            test_provider_dependency_stub.returns('test')
            injector.types =
                test:
                    name: 'test'
                    dependencies: ['transient_test']
                    type: class test_type
                        constructor: (@transient_test) ->
                    lifetime: 'transient'
                singleton_test:
                    name: 'singleton_test'
                    dependencies: null
                    type: class singleton_test_type
                    lifetime: 'singleton'
                transient_test:
                    name: 'transient_test'
                    dependencies: null
                    type: class transient_test_type
                    lifetime: 'transient'
                instance_test:
                    name: 'instance_test'
                    dependencies: null
                    type: class instance_test_type
                    lifetime: 'instance'
                parent_test:
                    name: 'parent_test'
                    dependencies: null
                    type: class parent_test_type
                    lifetime: 'parent'
                test_dependency:
                    name: 'test_dependency'
                    dependencies: null
                    type: class test_dependency
                    lifetime: 'transient'
            injector.providers =
                test_provider:
                    name: 'test_provider'
                    dependencies: null
                    type: test_provider_spy
                    lifetime: 'transient'
                test_provider_dependency:
                    name: 'test_provider_dependency'
                    dependencies: null
                    type: test_provider_dependency_stub
                    lifetime: 'transient'
        describe 'singleton', () ->
            it 'creates one instance of the type per injector', () ->
                first_singleton_instance = injector.instantiate('singleton_test')
                second_singleton_instance = injector.instantiate('singleton_test')

                expect(first_singleton_instance).toBe second_singleton_instance
        describe 'transient', () ->
            it 'creates one instance of the type per dependency requirement', () ->
                first_transient_instance = injector.instantiate 'transient_test'
                second_transient_instance = injector.instantiate 'transient_test'

                expect(first_transient_instance).not.toBe second_transient_instance

            it 'creates one instance of the type per dependency requirement when they are part of a parent dependency', () ->
                first_test_instance = injector.instantiate 'test'
                second_test_instance = injector.instantiate 'test'

                expect(first_test_instance.transient_test).not.toBe second_test_instance.transient_test

        describe 'instance', () ->
            it 'creates one instance of the type per invocation of the inject function'
        describe 'parent', () ->
            it 'creates one instance of the type for a dependency and all of its dependencies'
            it 'creates a different instance of the type for a sibling dependency'