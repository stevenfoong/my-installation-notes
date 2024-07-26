The following command shows the size of each of the logs in your docker containers.  
```
docker ps -aq | xargs -I '{}' docker inspect --format='{{.LogPath}}' '{}' | xargs ls -lh
```
`fallocate --collapse-range --offset 0 --length 130GiB --verbose /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log`

use this command to reduce the file size  
```
fallocate --collapse-range --offset 0 --length 1GiB --verbose
```
