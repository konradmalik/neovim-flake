{ buildDotnetGlobalTool, dotnetCorePackages }:
buildDotnetGlobalTool {
  pname = "csharp-ls";
  version = "0.10.0";

  nugetSha256 = "sha256-1t8U2Q4lIlj2QwbnevAMMGcqtpPh5zk0Bd7EHa7qvCI=";

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;
}
