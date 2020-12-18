package com.netease.router_compiler;

import com.google.auto.service.AutoService;
import com.netease.router_ani.Route;
import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.JavaFile;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;

import java.io.IOException;
import java.util.Set;

import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Filer;
import javax.annotation.processing.Messager;
import javax.annotation.processing.ProcessingEnvironment;
import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.util.Elements;
import javax.tools.Diagnostic;

@AutoService(Processor.class)
@SupportedAnnotationTypes({"com.netease.router_ani.Route"})
@SupportedSourceVersion(SourceVersion.RELEASE_7)
public class RouteProcessor extends AbstractProcessor {

    private Elements elementUtils;

    public Filer filer;

    // Messager用来报告错误，警告和其他提示信息
    private Messager messager;

    @Override
    public boolean process(Set<? extends TypeElement> set, RoundEnvironment roundEnvironment) {

        messager.printMessage(Diagnostic.Kind.NOTE, "start process");

        Set<? extends Element> elements = roundEnvironment.getElementsAnnotatedWith(Route.class);

        /**
         * 生成构造方法，在构造方法中初始化map
         */
        MethodSpec.Builder constructorBuilder = MethodSpec.constructorBuilder()
                .addModifiers(Modifier.PUBLIC);

        String moduleName = null;


        for (Element element : elements) {
            TypeElement typeElement = (TypeElement) element;
            Route route = typeElement.getAnnotation(Route.class);
            if (moduleName == null || moduleName.length() < 1) {
                moduleName = route.moduleName();
            }
            ClassName className = (ClassName) ClassName.get(typeElement.asType());
            constructorBuilder.addStatement("routerMap.put($S,$S)", route.value(), className.packageName() + "." + className.simpleName());
        }

        if (moduleName == null || moduleName.length() < 1) {
            return false;
        }
        final ClassName routerSuper = ClassName.get("com.netease.router", "RouterMap");

        TypeSpec routerInit = TypeSpec.classBuilder(moduleName + "_RouterMapImpl")
                .addModifiers(Modifier.PUBLIC)
                .superclass(routerSuper)
                .addMethod(constructorBuilder.build())
                .build();

        JavaFile javaFile = JavaFile.builder("com.netease.router.map", routerInit).build();
        try {
            javaFile.writeTo(filer);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    @Override
    public synchronized void init(ProcessingEnvironment processingEnvironment) {
        super.init(processingEnvironment);
        filer = processingEnvironment.getFiler();
        messager = processingEnvironment.getMessager();
        elementUtils = processingEnvironment.getElementUtils();
        messager.printMessage(Diagnostic.Kind.NOTE, "router map processor Init");
    }

}
