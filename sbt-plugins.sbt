addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.1.0")

// addSbtPlugin("org.lifty" % "lifty" % "1.7.4")


resolvers += "sbt-idea-repo" at "http://mpeltonen.github.com/maven/"

addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.1.0")


resolvers += Resolver.url("heikoseeberger", new URL("http://hseeberger.github.com/releases"))(Resolver.ivyStylePatterns)

addSbtPlugin("name.heikoseeberger.groll" % "groll" % "1.3.0")


