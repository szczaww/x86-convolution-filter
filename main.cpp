#include <stdio.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <iostream>
#include <string>


extern "C" void convolution(Uint32* image_pixel_map); //, Uint32* result_pixel_map, int width, int height, int mouse_x, int mouse_y);


void redrawWindow(SDL_Texture* texture, SDL_Renderer* renderer, int pitch, Uint32* pixels) {
    // Update the texture with the pixel buffer
    SDL_UpdateTexture(texture, nullptr, pixels, pitch);

    // Clear the renderer and copy the texture to the renderer
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, nullptr, nullptr);
    SDL_RenderPresent(renderer);
}


int main(int argc, char *argv[]) {
    // for (int i = 1; i < argc; i++)
    //     printf("%d: %s\n", i, convolution(argv[i]));
    
    const char* path = "IFiles/julia1.bmp";
    int width = 512;
    int height = 512;

    if (argc == 2) {
        path = argv[2];
    }
    // if (argc == 4) {
    //     path = argv[2];
    //     width = std::stoi(argv[3]);
    //     height = std::stoi(argv[4]);
    // }


   // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "Failed to initialize SDL: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Create a window
    SDL_Window* window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
    if (window == nullptr) {
        std::cerr << "Failed to create SDL window: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Create a renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == nullptr) {
        std::cerr << "Failed to create SDL renderer: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    
    // Load image from path
    SDL_Surface* surface = IMG_Load(path);
    if (surface == nullptr) {
        std::cerr << "IMG_Load Error: " << IMG_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    // Create a image pixel buffer
    Uint32* image_pixel_map = (Uint32*)surface->pixels;
    Uint32* result_pixel_map = new Uint32[width * height];

    // ============================================================================= //

    SDL_Surface* test_surface1 = IMG_Load("IFiles/julia3.bmp");
    Uint32* test_map1 = (Uint32*)test_surface1->pixels;
    int test_map_pitch1 = test_surface1->pitch;

    SDL_Surface* test_surface2 = IMG_Load("IFiles/julia2.bmp");
    Uint32* test_map2 = (Uint32*)test_surface2->pixels;
    int test_map_pitch2 = test_surface2->pitch;
    
    // ============================================================================= //

    // Make texture from surface
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    if (texture == nullptr) {
        std::cerr << "Failed to create SDL texture: " << SDL_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Free surface
    SDL_FreeSurface(surface);
    // Clear renderer
    SDL_RenderClear(renderer);
    // Render texture
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    // Present renderer
    SDL_RenderPresent(renderer);

    // Mouse location variables
    int mouse_x = 0;
    int mouse_y = 0;

    int i = 0;

    bool quit = false;
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) {
            // switch (event.type) {
            //     case (SDL_QUIT):
            //         quit = true;
            //     case (SDL_MOUSEBUTTONDOWN):
            //         SDL_GetMouseState(&mouse_x, &mouse_y); 
            //     // case (SDL_MOUSEMOTION):
            //     //     SDL_GetMouseState(&mouse_x, &mouse_y);
            //     //
            //     //case (SDL_KEYDOWN):
            //     //     switch (event.key.keysym.sym) {
            //     //         case SDLK_RIGHT:
            //     //             printf("Left key pressed");
            if (event.type == SDL_QUIT) {
                    quit = true;
            }
            else if (event.type == SDL_MOUSEBUTTONDOWN) {
                SDL_GetMouseState(&mouse_x, &mouse_y);
                //convolution(result_pixel_map); // width, height, mouse_x, mouse_y);
                i++;
                if (i%2 ==0) {
                    redrawWindow(texture, renderer, test_map_pitch1, test_map1);
                } else {
                    redrawWindow(texture, renderer, test_map_pitch2, test_map2);
                }
            }
        }
    }

    //std::cout << "Mouse x:" << mouse_x;
    //std::cout << "Mouse y:" << mouse_y;
    printf("%s: %d\n", "Mouse x:", mouse_x);
    printf("%s: %d\n", "Mouse y:", mouse_y);

    // Clean up
    delete[] image_pixel_map;
    delete[] result_pixel_map;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;    
}