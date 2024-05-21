#include <stdio.h>
#include <GL/glut.h>

extern "C" char *convolution(char *s);


void display();
void init();

int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++)
        printf("%d: %s\n", i, mystrrev(argv[i]));

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(800, 600);
    glutCreateWindow("OpenGL Example");

    init();

    glutDisplayFunc(display);
    glutMainLoop();

    return 0;
}

void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
}

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBegin(GL_TRIANGLES);
        glColor3f(1.0, 0.0, 0.0); // Red
        glVertex3f(-0.5, -0.5, 0.0);
        glColor3f(0.0, 1.0, 0.0); // Green
        glVertex3f(0.5, -0.5, 0.0);
        glColor3f(0.0, 0.0, 1.0); // Blue
        glVertex3f(0.0, 0.5, 0.0);
    glEnd();

    glutSwapBuffers();
}

