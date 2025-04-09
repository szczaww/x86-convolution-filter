<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Stargazers][stars-shield]][stars-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
![C++](https://img.shields.io/badge/c++-%2300599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)


<!-- ABOUT THE PROJECT -->
## About
This project is an interactive visualization of a convolution filter, written in x86-64 assembly with a basic C++ frontend. It transforms bitmap images  producing a mixed effect of saturation & blur of intensity depending on current cursor position.  
The following mask is used, where r would be the pixel distance from your mouse:

```
[  0  -1   0 ]     [ 1  2  1 ]
[ -1   5  -1 ]  +  [ 2 -4  2 ]  ×  min( r / (2 × min(width, height)),  1 )
[  0  -1   0 ]     [ 1  2  1 ]
```

It was developed as part of the assembly intro course at Warsaw University of Technology.

## Installation & usage

1. Clone the repo
   ```
   git clone https://github.com/szczaww/x86-convolution-filter
   ```
2. Build the project
   ```
   make
   ```
3. Run for your image of choice 
   ```
   ./build/app in/<image-name>.bmp
   ```
4. Left click to update cursor position & right click to reset image back to normal

<!-- MARKDOWN LINKS & IMAGES -->
[stars-shield]: https://img.shields.io/github/stars/szczaww/c89-virtual-disk-file.svg?style=for-the-badge
[stars-url]: https://github.com/szczaww/c89-virtual-disk-file/stargazers
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: www.linkedin.com/in/kamil-szczawinski
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: www.linkedin.com/in/kamil-szczawinski
