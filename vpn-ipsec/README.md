## IPSEC SITE TO SITE 
### With StrongSwan

Example ipsec with [**StrongSwan**](https://www.strongswan.org) in vagrant with:
- IKEv1
- Pre-Shared Key
- Phase1:
    - Encryption Algorithm   -> 3DES
    - Hash Algorithm         -> SHA256
    - DH Group               -> 2 (1024)
- Phase2:
    - Encryption Algorithm   -> 3DES
    - Hash Algorithm         -> MD5
    - DH Group               -> 2 (1024)

# Diagram:
~~~                                                                    
                                                  10.10.3.5  *************** 
                                                             *   SUN       * 
                                                        ******             * 
                                                        *    *   CLIENT 1  * 
                        MOON                    SUN     *    *             *
                         10.10.0.10      10.10.0.20     *    *************** 
 ****************      *********            *********   *
 *              *      *       *            *       *****  10.10.3.2  
 * MOON-CLIENT  ********       **************       *                    
 *              *      *       *            *       *****  10.10.4.2                   
 ****************      *********            *********   *    
    10.10.2.5       10.10.2.2                           *    *************** 
                                                        *    *   SUN       * 
                                                        *    *             * 
                                                        ******   CLIENT 2  * 
                                                             *             * 
                                                  10.10.4.5  ***************
~~~

With this machines you can connex the moon-client machine to sun-client. Asume the connection between Moon and Sun is Internet or any no secure network. 

## With Certificate
To use it change in *ipsec.conf*:
~~~ 
## Comment 
    leftauth = psk
    rightauth = psk 

## And uncomment:
    leftcert = moon.com.cert.pem
    leftfirewall = yes
~~~

And in *ipsec.secrets*:
~~~
## Comment
%any 10.10.0.20 : PSK "123123123

## Uncomment
: RSA moon.com.key.pem
~~~

Do it in moon-server and sun-server.

If you want to generate your own certificates, StrongSwan explain it [here](https://wiki.strongswan.org/projects/strongswan/wiki/SimpleCA).