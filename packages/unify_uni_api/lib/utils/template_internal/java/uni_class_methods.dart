const javaUniApiClassMethods = '''
    public static Map<String, Object> moduleMap = new HashMap<>();

    public static void registerModule(Object module) {
        Class[] interfaces = module.getClass().getInterfaces();
        if (interfaces.length == 0) {
            moduleMap.put(module.getClass().getName(), module);
        } else {
            moduleMap.put(module.getClass().getInterfaces()[0].getName(), module);
        }
    }

    public static<T> T get(Class<T> aClass) {
        return (T) moduleMap.get(aClass.getName());
    }
''';
