{ pkgs, sources, ... }:

{
  system.activationScripts.ldso = pkgs.lib.stringAfter [ "usrbinenv" ] ''                       
    mkdir -m 0755 -p /lib64                                                                
    ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp   
    mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace 
  '';                                                                                      

}
