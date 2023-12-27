scalaVersion := "2.12.12"

libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.5.6"
libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % "0.5.6"

addCompilerPlugin("edu.berkeley.cs" % "chisel3-plugin" % "3.5.6" cross CrossVersion.full)

