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

int main(int argc, char *argv[]) {
    // Prepare variables
    int mouse_x = 0;
    int mouse_y = 0;
    int new_x = 0;
    int new_y = 0;
    const char* path = "IFiles/view.bmp";

    if (argc >= 1) {
        path = argv[1];
    }

   // Initialize SDL
    SDL_Init(SDL_INIT_VIDEO);   

    // Load image and extract info
    SDL_Surface* og_surface = IMG_Load(path);
    SDL_Surface* surface = SDL_ConvertSurfaceFormat(og_surface, SDL_PIXELFORMAT_ARGB8888, 0);
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
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);                   // Create texture

    SDL_RenderClear(renderer);                                      // Clear renderer
    SDL_UpdateTexture(texture, nullptr, image_pixel_map, pitch);    // Update texture with the correct pitch
    SDL_RenderCopy(renderer, texture, NULL, NULL);                  // Render texture
    SDL_RenderPresent(renderer);                                    // Present renderer

    redrawWindow(texture, renderer, pitch, image_pixel_map);

    bool mouse_down = false;
    bool convolution_displayed = false;
    bool quit = false;
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) 
        {
            switch (event.type)
            {
                case SDL_QUIT:
                    quit = true;
                    break;
            
                case SDL_MOUSEBUTTONDOWN:        
                    switch (event.button.button)
                    {
                        case SDL_BUTTON_LEFT:
                            convolution_displayed = true;
                            mouse_down = true;
                            break;

                        case SDL_BUTTON_RIGHT:
                            if (convolution_displayed == true) {
                                redrawWindow(texture, renderer, pitch, image_pixel_map);
                                convolution_displayed = false;
                            } else {
                                redrawWindow(texture, renderer, pitch, result_pixel_map);
                                convolution_displayed = true;
                            }
                            break;
                    }
                    break;

                case SDL_MOUSEBUTTONUP:
                    switch (event.button.button) {
                        case SDL_BUTTON_LEFT:
                            mouse_down = false;
                            break;
                    }
                    break;

                default:
                    if (mouse_down == false) {
                        break;
                    }

                    SDL_GetMouseState(&new_x, &new_y);
                    if (new_x == mouse_x && new_y == mouse_y) {
                        break;
                    }
                    
                    mouse_x = new_x;
                    mouse_y = new_y;

                    convolution(image_pixel_map, result_pixel_map, width, height, mouse_x, mouse_y, bpp);
                    redrawWindow(texture, renderer, pitch, result_pixel_map);
                    break;
            }
        }
    }

    // Clean up
    SDL_FreeSurface(surface);
    SDL_FreeSurface(og_surface);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;    
}