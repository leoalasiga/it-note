# Spring Boot Actuator: Production-ready Features生产准备功能

> Spring Boot includes a number of additional features to help you monitor and manage your application when you push it to production. You can choose to manage and monitor your application by using HTTP endpoints or with JMX. Auditing, health, and metrics gathering can also be automatically applied to your application.

Spring Boot包含了数种额外的功能来帮助你监控和管理你的应用,当你将它推送到生产上,你可以选择通过HTTP endpoints 或者通过JMX去管理和监控你的应用.审计,健康以及指标收集,可以自动应用到你的应用中



## 1. Enabling Production-ready Features

The [`spring-boot-actuator`](https://github.com/spring-projects/spring-boot/tree/v2.5.1/spring-boot-project/spring-boot-actuator) module provides all of Spring Boot’s production-ready features. The recommended way to enable the features is to add a dependency on the `spring-boot-starter-actuator` ‘Starter’.

Spring Boot Actuator模块提供了所有的springboot的生产准备功能,启用这些功能的推荐方法是添加``spring-boot-starter-actuator`的依赖

```txt
Definition of Actuator
Acutator的定义
An actuator is a manufacturing term that refers to a mechanical device for moving or controlling something. Actuators can generate a large amount of motion from a small change.
执行器是一个制造术语，指的是用于移动或控制某物的机械装置,执行器可以从一个小的变化产生大量的运动。

```



+ maven

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

+ gradle

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```



## 2. Endpoints

Actuator endpoints let you monitor and interact with your application. Spring Boot includes a number of built-in endpoints and lets you add your own. For example, the `health` endpoint provides basic application health information.

Actuator endpoints 让你监控并与你的应用互动,Spring Boot包含大量内置endpoint 并且允许你添加你自己的,如,health endpoint提供了应用的基本健康信息



Each individual endpoint can be [enabled or disabled](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints.enabling) and [exposed (made remotely accessible) over HTTP or JMX](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints.exposing). An endpoint is considered to be available when it is both enabled and exposed. The built-in endpoints will only be auto-configured when they are available. Most applications choose exposure via HTTP, where the ID of the endpoint along with a prefix of `/actuator` is mapped to a URL. For example, by default, the `health` endpoint is mapped to `/actuator/health`.

每个独立的endpoint 可以被启用或禁用,也可以通过HTTP或JMX暴露(远程服务可接入).当endpoint启用且暴露,它被认为是可用的,内置端点只有在可用时才会自动配置.大多数应用程序选择通过HTTP公开，其中端点的ID和前缀`/actuator`被映射到URL。例如，默认情况下，“health”端点映射到“/actuator/health”。

可使用以下技术无关的端点：

| ID             | **Description**                                              |
| -------------- | ------------------------------------------------------------ |
| auditevents    | Exposes audit events information for the current application. Requires an `AuditEventRepository` bean.公开当前应用程序的审核事件信息,需要一个`AuditEventRepository`bean |
| beans          | Displays a complete list of all the Spring beans in your application.显示应用程序中所有Spring beans的完整列表。 |
| caches         | Exposes available caches. 公开可用的缓存                     |
| conditions     | Shows the conditions that were evaluated on configuration and auto-configuration classes and the reasons why they did or did not match.显示在配置和自动配置类上评估的条件以及它们匹配或不匹配的原因。 |
| configprops    | Displays a collated list of all `@ConfigurationProperties`.显示所有“@ConfigurationProperties”的整理列表 |
| env            | Exposes properties from Spring’s `ConfigurableEnvironment`.公开Spring的 `ConfigurableEnvironment`的属性 |
| flyway         | Shows any Flyway database migrations that have been applied. Requires one or more `Flyway` beans.显示已应用的所有Flyway数据库迁移。需要一个或多个Flyway bean。 |
| health         | Shows application health information. 展示应用的健康信息     |
| httptrace      | Shows the Spring Integration graph. Requires a dependency on `spring-integration-core`.显示Spring的集成图,需要依赖`spring-integration-core` |
| loggers        | Shows and modifies the configuration of loggers in the application.展示和修改应用的日志配置 |
| liquibase      | Shows any Liquibase database migrations that have been applied. Requires one or more `Liquibase` beans.显示已应用的所有Liquibase 数据库迁移。需要一个或多个Liquibase bean。 |
| metrics        | Shows ‘metrics’ information for the current application.显示当前应用程序的“度量”信息。 |
| mappings       | Displays a collated list of all `@RequestMapping` paths.显示所有“@RequestMapping”的整理列表 |
| quartz         | Shows information about Quartz Scheduler jobs.显示Quartz 定时任务信息 |
| scheduledtasks | Displays the scheduled tasks in your application.展示你的应用定时任务 |
| sessions       | Allows retrieval and deletion of user sessions from a Spring Session-backed session store. Requires a Servlet-based web application using Spring Session.允许从支持Spring会话的会话存储中检索和删除用户会话。需要使用Spring会话的基于Servlet的web应用程序 |
| shutdown       | Lets the application be gracefully shutdown. Disabled by default.应用优雅的关闭,默认禁用 |
| startup        | Shows the [startup steps data](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.spring-application.startup-tracking) collected by the `ApplicationStartup`. Requires the `SpringApplication` to be configured with a `BufferingApplicationStartup`.显示启动步骤数据,要求将“SpringApplication”配置为“BufferingApplicationStartup” |
| threaddump     | Performs a thread dump.执行线程转储                          |

If your application is a web application (Spring MVC, Spring WebFlux, or Jersey), you can use the following additional endpoints:

如果你的引用是web应用(Spring MVC, Spring WebFlux, or Jersey),你可以使用下面的endpoints:

| **ID**     | **Description** |
| ---------- | --------------- |
| heapdump   |                 |
| jolokia    |                 |
| logfile    |                 |
| prometheus |                 |

