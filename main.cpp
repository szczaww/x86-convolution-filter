#include <stdio.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <iostream>
#include <fstream>
#include <string>


extern "C" void convolution(Uint32* image_pixel_map, Uint32* result_pixel_map, int width, int height, int mouse_x, int mouse_y, int bytes_per_pixel);

void redrawWindow(SDL_Texture* texture, SDL_Renderer* renderer, int pitch, Uint32* pixels) {
    SDL_RenderClear(renderer);                              // Clear the renderer
    SDL_UpdateTexture(texture, nullptr, pixels, pitch);     // Update the texture with the pixel buffer
    SDL_RenderCopy(renderer, texture, nullptr, nullptr);    // Copy the texture to the renderer
    SDL_RenderPresent(renderer);                            // Display
}

int main() {
    // Prepare variables
    int mouse_x = 0;
    int mouse_y = 0;
    const char* path = "IFiles/flower.bmp";

   // Initialize SDL
    SDL_Init(SDL_INIT_VIDEO);   

    // Load image and extract info
    SDL_Surface* surface = IMG_Load(path);
    int width = surface->w; 
    int height = surface->h;
    int pitch = surface->pitch;
    int bpp = surface->format->BytesPerPixel;
    Uint32* image_pixel_map = (Uint32*)surface->pixels;
    Uint32* result_pixel_map = new Uint32[width * height];

    // Print for debugging
    printf("%s %u\n", "Width:", width);
    printf("%s %u\n", "Height:", height);
    printf("%s %u\n", "Pitch:", pitch);
    printf("%s %u\n", "Bpp:", bpp);
    printf("\n");


    SDL_Window* window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);   // Create a window
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);                                                          // Create a renderer
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);                                                                     // Make texture from surface

    SDL_RenderClear(renderer);                      // Clear renderer
    SDL_RenderCopy(renderer, texture, NULL, NULL);  // Render texture
    SDL_RenderPresent(renderer);                    // Present renderer


    bool quit = false;
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) 
        {
            if (event.type == SDL_QUIT) {
                    quit = true;
            }
            else if (event.type == SDL_MOUSEBUTTONDOWN) {
                SDL_GetMouseState(&mouse_x, &mouse_y);
                printf("%s: %d\n", "Mouse x:", mouse_x);
                printf("%s: %d\n", "Mouse y:", mouse_y);
                printf("\n");

                convolution(image_pixel_map, result_pixel_map, width, height, mouse_x, mouse_y, bpp);
                redrawWindow(texture, renderer, pitch, result_pixel_map);
                
            }
        }
    }

    // Clean up
    // delete[] image_pixel_map;
    // delete[] result_pixel_map;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;    
}