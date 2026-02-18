# The nix-eda flake template
{
  inputs = {
    librelane.url = "github:librelane/librelane/ihp";
  };

  outputs = {
    self,
    librelane,
    ...
  }: {
    devShells = librelane.devShells;
  };
}
