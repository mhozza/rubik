#include "common_header.h"

#include "win_OpenGLApp.h"

#include "shaders.h"
#include "texture.h"
#include "vertexBufferObject.h"

#include "flyingCamera.h"

#include "freeTypeFont.h"

#include "skybox.h"

#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#define FRONT 0
#define BACK 1
#define LEFT 2
#define RIGHT 3
#define TOP 4
#define BOT 5

/* One VBO, where all static data are stored now,
in this tutorial vertex is stored as 3 floats for
position, 2 floats for texture coordinate and
3 floats for normal vector. */

CVertexBufferObject vboSceneObjects;
UINT uiVAOs[1]; // Only one VAO now

CShader shShaders[5];
CShaderProgram spDirectionalLight, spOrtho2D, spFont2D;

#define NUMTEXTURES 3

CTexture tTextures[NUMTEXTURES];

CFlyingCamera cCamera;

CFreeTypeFont ftFont;

CSkybox sbMainSkybox;

bool bMatchedColors = true;

/*-----------------------------------------------

Name:		initScene

Params:	lpParam - Pointer to anything you want.

Result:	Initializes OpenGL features that will
			be used.

/*---------------------------------------------*/

#include "static_geometry.h"

int iTorusFaces;

#include "match_color.h"

glm::vec4 vRubikColors[7] = 
{
	glm::vec4(1.0f, 0.0f, 0.0f, 1.0f), // Red
	glm::vec4(0.0f, 1.0f, 0.0f, 1.0f), // Green
	glm::vec4(0.0f, 0.0f, 1.0f, 1.0f), // Blue
	glm::vec4(1.0f, 0.5f, 0.0f, 1.0f), // Orange
	glm::vec4(1.0f, 1.0f, 0.0f, 1.0f), // Yellow
	glm::vec4(1.0f, 1.0f, 1.0f, 1.0f), // White
	glm::vec4(0.0f, 0.0f, 0.0f, 1.0f) // Black
};

glm::vec4 rgbcolortomyrgb(rgbcolor rgb)
{
	return glm::vec4(float(rgb.r)/255.0f, float(rgb.g)/255.0f, float(rgb.b)/255.0f, 1.0f);
}

class CRubikSubcube
{
public:
	int iSideColors[6];
	glm::vec4 vRealColor[6];
};

CRubikSubcube subCubes[3][3][3];
float fSubcubeSize = 5.0f;

bool bRotatingWall[6] = {false, false, false, false, false, false};
bool bClockwiseRotation;


vector<int> CubeWalls[3][3][3];

int iLastClickedCube = -1;
int iSelectedWallIndex = 0;
int iSelectedWall = -1;

bool ShouldHighLight(int iWall, int y, int x, int z)
{
	if(iWall == FRONT)return z == 2;
	if(iWall == BACK)return z == 0;
	if(iWall == LEFT)return x == 0;
	if(iWall == RIGHT)return x == 2;
	if(iWall == TOP)return y == 0;
	if(iWall == BOT)return y == 2;

	return false;
}

void ExtractIndices(int index, int* y, int* x, int* z)
{
	*y = index/9;
	*x = (index%9)/3;
	*z = index%3;
}

int PackIndices(int y, int x, int z)
{
	return y*9 + x*3 + z;
}


char sTxtFile1[255], sTxtFile2[255];

void initScene(LPVOID lpParam)
{
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

	vboSceneObjects.createVBO();
	glGenVertexArrays(1, uiVAOs); // Create one VAO
	glBindVertexArray(uiVAOs[0]);

	vboSceneObjects.bindVBO();

	// Add cube to VBO

	FOR(i, 36)
	{
		vboSceneObjects.addData(&vCubeVertices[i], sizeof(glm::vec3));
		vboSceneObjects.addData(&vCubeTexCoords[i%6], sizeof(glm::vec2));
		vboSceneObjects.addData(&vCubeNormals[i/6], sizeof(glm::vec3));
	}

	// Add ground to VBO

	FOR(i, 6)
	{
		vboSceneObjects.addData(&vGround[i], sizeof(glm::vec3));
		vCubeTexCoords[i] *= 10.0f;
		vboSceneObjects.addData(&vCubeTexCoords[i%6], sizeof(glm::vec2));
		glm::vec3 vGroundNormal(0.0f, 1.0f, 0.0f);
		vboSceneObjects.addData(&vGroundNormal, sizeof(glm::vec3));
	}

	iTorusFaces = generateTorus(vboSceneObjects, 7.0f, 2.0f, 20, 20);
	vboSceneObjects.uploadDataToGPU(GL_STATIC_DRAW);

	// Vertex positions
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 2*sizeof(glm::vec3)+sizeof(glm::vec2), 0);
	// Texture coordinates
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2*sizeof(glm::vec3)+sizeof(glm::vec2), (void*)sizeof(glm::vec3));
	// Normal vectors
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 2*sizeof(glm::vec3)+sizeof(glm::vec2), (void*)(sizeof(glm::vec3)+sizeof(glm::vec2)));

	// Load shaders and create shader programs

	shShaders[0].loadShader("data\\shaders\\shader.vert", GL_VERTEX_SHADER);
	shShaders[1].loadShader("data\\shaders\\shader.frag", GL_FRAGMENT_SHADER);
	shShaders[2].loadShader("data\\shaders\\ortho2D.vert", GL_VERTEX_SHADER);
	shShaders[3].loadShader("data\\shaders\\ortho2D.frag", GL_FRAGMENT_SHADER);
	shShaders[4].loadShader("data\\shaders\\font2D.frag", GL_FRAGMENT_SHADER);

	spDirectionalLight.createProgram();
	spDirectionalLight.addShaderToProgram(&shShaders[0]);
	spDirectionalLight.addShaderToProgram(&shShaders[1]);
	spDirectionalLight.linkProgram();

	spOrtho2D.createProgram();
	spOrtho2D.addShaderToProgram(&shShaders[2]);
	spOrtho2D.addShaderToProgram(&shShaders[3]);
	spOrtho2D.linkProgram();

	spFont2D.createProgram();
	spFont2D.addShaderToProgram(&shShaders[2]);
	spFont2D.addShaderToProgram(&shShaders[4]);
	spFont2D.linkProgram();

	// Load textures

	string sTextureNames[] = {"ik_itrimv_128b.jpg", "crate.jpg", "crate_nyan.jpg"};

	FOR(i, NUMTEXTURES) // I know that FOR cycle is useless now, but it was easier to rewrite :)
	{
		tTextures[i].loadTexture2D("data\\textures\\"+sTextureNames[i], true);
		tTextures[i].setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_BILINEAR_MIPMAP);
	}

	glEnable(GL_DEPTH_TEST);
	glClearDepth(1.0);
	glClearColor(0.0f, 0.26f, 0.48f, 1.0f);

	// Here we load font with pixel size 32 - this means that if we print with size above 32, the quality will be low
	ftFont.loadSystemFont("arial.ttf", 32);
	ftFont.setShaderProgram(&spFont2D);
	
	cCamera = CFlyingCamera(glm::vec3(0.0f, 30.0f, 30.0f), glm::vec3(0.0f, 29.8f, 29.0f), glm::vec3(0.0f, 1.0f, 0.0f), 50.0f, 0.1f);
	cCamera.setMovingKeys('W', 'S', 'A', 'D');

	sbMainSkybox.loadSkybox("data\\skyboxes\\jajspace1\\", "jajspace1_ft.jpg", "jajspace1_bk.jpg", "jajspace1_lf.jpg", "jajspace1_rt.jpg", "jajspace1_up.jpg", "jajspace1_dn.jpg");

	FOR(y, 3)FOR(x, 3)FOR(z, 3)
	{
		FOR(k, 6)subCubes[y][x][z].iSideColors[k] = rand()%6;
	}

	FOR(y, 3)FOR(x, 3)FOR(z, 3)
	{
		if(x == 0)CubeWalls[y][x][z].push_back(LEFT);
		if(x == 2)CubeWalls[y][x][z].push_back(RIGHT);

		if(y == 0)CubeWalls[y][x][z].push_back(TOP);
		if(y == 2)CubeWalls[y][x][z].push_back(BOT);

		if(z == 0)CubeWalls[y][x][z].push_back(BACK);
		if(z == 2)CubeWalls[y][x][z].push_back(FRONT);
	}

	vRubikColors[0] = rgbcolortomyrgb(RED); vRubikColors[1] = rgbcolortomyrgb(GREEN); vRubikColors[2] = rgbcolortomyrgb(BLUE);
	vRubikColors[3] = rgbcolortomyrgb(ORANGE); vRubikColors[4] = rgbcolortomyrgb(YELLOW); vRubikColors[5] = rgbcolortomyrgb(WHITE);

	if(sTxtFile1[0] != 0 && sTxtFile2[0] != 0)
	{
		FOR(y, 3)FOR(x, 3)FOR(z, 3)
		{
			FOR(k, 6)subCubes[y][x][z].iSideColors[k] = 6; // Black
		}
		FILE* fp = fopen(sTxtFile1, "rt");

		int iMappingTop[] = {PackIndices(0, 0, 0), PackIndices(0, 1, 0), PackIndices(0, 2, 0),
			PackIndices(0, 0, 1), PackIndices(0, 1, 1), PackIndices(0, 2, 1),
			PackIndices(0, 0, 2), PackIndices(0, 1, 2), PackIndices(0, 2, 2)};

		int iMappingFront[] = {PackIndices(0, 0, 2), PackIndices(0, 1, 2), PackIndices(0, 2, 2),
			PackIndices(1, 0, 2), PackIndices(1, 1, 2), PackIndices(1, 2, 2),
			PackIndices(2, 0, 2), PackIndices(2, 1, 2), PackIndices(2, 2, 2)};

		int iMappingRight[] = {PackIndices(0, 2, 2), PackIndices(0, 2, 1), PackIndices(0, 2, 0),
			PackIndices(1, 2, 2), PackIndices(1, 2, 1), PackIndices(1, 2, 0),
			PackIndices(2, 2, 2), PackIndices(2, 2, 1), PackIndices(2, 2, 0)};

		rgbcolor orders[] = {RED, GREEN, BLUE, ORANGE, YELLOW, WHITE};

		FOR(i, 9) // Front wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);

			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingFront[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[FRONT] = ind;
			subCubes[y][x][z].vRealColor[FRONT] = rgbcolortomyrgb(clr);
		}

		FOR(i, 9) // Right wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);
			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingRight[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[RIGHT] = ind;
			subCubes[y][x][z].vRealColor[RIGHT] = rgbcolortomyrgb(clr);
		}

		FOR(i, 9) // Top wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);
			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingTop[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[TOP] = ind;
			subCubes[y][x][z].vRealColor[TOP] = rgbcolortomyrgb(clr);
		}
		fclose(fp);




		fp = fopen(sTxtFile2, "rt");

		int iMappingLeft[] = {PackIndices(2, 0, 2), PackIndices(2, 0, 1), PackIndices(2, 0, 0),
			PackIndices(1, 0, 2), PackIndices(1, 0, 1), PackIndices(1, 0, 0),
			PackIndices(0, 0, 2), PackIndices(0, 0, 1), PackIndices(0, 0, 0)};

		int iMappingBack[] = {PackIndices(2, 0, 0), PackIndices(2, 1, 0), PackIndices(2, 2, 0),
			PackIndices(1, 0, 0), PackIndices(1, 1, 0), PackIndices(1, 2, 0),
			PackIndices(0, 0, 0), PackIndices(0, 1, 0), PackIndices(0, 2, 0)};

		int iMappingBottom[] = {PackIndices(2, 2, 2), PackIndices(2, 2, 1), PackIndices(2, 2, 0),
			PackIndices(2, 1, 2), PackIndices(2, 1, 1), PackIndices(2, 1, 0),
			PackIndices(2, 0, 2), PackIndices(2, 0, 1), PackIndices(2, 0, 0)};

		FOR(i, 9) // Left wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);

			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingLeft[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[LEFT] = ind;
			subCubes[y][x][z].vRealColor[LEFT] = rgbcolortomyrgb(clr);
		}

		FOR(i, 9) // Back wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);
			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingBack[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[BACK] = ind;
			subCubes[y][x][z].vRealColor[BACK] = rgbcolortomyrgb(clr);
		}

		FOR(i, 9) // Bottom wall
		{
			rgbcolor clr; fscanf(fp, "%d %d %d", &clr.r, &clr.g, &clr.b);
			rgbcolor matched = match_color(clr);
			int ind = 6;
			FOR(j, 6)if(orders[j].r == matched.r && orders[j].g == matched.g && orders[j].b == matched.b)
			{
				ind = j;
				break;
			}
			int y, x, z;
			ExtractIndices(iMappingBottom[i], &y, &x, &z);
			subCubes[y][x][z].iSideColors[BOT] = ind;
			subCubes[y][x][z].vRealColor[BOT] = rgbcolortomyrgb(clr);
		}
		fclose(fp);


	}

}

/*-----------------------------------------------

Name:	renderScene

Params:	lpParam - Pointer to anything you want.

Result:	Renders whole scene.

/*---------------------------------------------*/

float fGlobalAngle;
float fRotatingAngle = 0.0;



void RotateWall(int* iIndices, bool bClockwise, int iMapping)
{
	CRubikSubcube sWall[9];
	int mapaClockwise[] = {2, 5, 8, 1, 4, 7, 0, 3, 6};
	int mapaCounterClockwise[] = {6, 3, 0, 7, 4, 1, 8, 5, 2};

	int* usedMapa = bClockwise ? mapaClockwise : mapaCounterClockwise;

	int iMapToFB[4] = {4, 3, 5, 2};
	int iMapToLR[4] = {4, 0, 5, 1};
	int iMapToTB[4] = {0, 2, 1, 3};

	int* iMappingTable = iMapping == 0 ? iMapToFB : (iMapping == 1 ? iMapToLR : iMapToTB);

	int iAdd = bClockwise ? 1 : 3;

	FOR(i, 9)
	{
		int y, x, z; ExtractIndices(iIndices[i], &y, &x, &z);
		memcpy(&sWall[usedMapa[i]], &subCubes[y][x][z], sizeof(CRubikSubcube));
	}
	FOR(i, 9)
	{
		int aa = sizeof(CRubikSubcube);
		int y, x, z; ExtractIndices(iIndices[i], &y, &x, &z);
		memcpy(&subCubes[y][x][z], &sWall[i], sizeof(CRubikSubcube));
		int iNewColorMap[6];
		glm::vec4 vNewColorMap[6];
		
		FOR(k, 4)
		{
			iNewColorMap[iMappingTable[(k+iAdd)%4]] = subCubes[y][x][z].iSideColors[iMappingTable[k]];
			vNewColorMap[iMappingTable[(k+iAdd)%4]] = subCubes[y][x][z].vRealColor[iMappingTable[k]];
		}
		FOR(k, 4)
		{
			subCubes[y][x][z].iSideColors[iMappingTable[k]] = iNewColorMap[iMappingTable[k]];
			subCubes[y][x][z].vRealColor[iMappingTable[k]] = vNewColorMap[iMappingTable[k]];
		}
	}

}

float nyansgn = 1;

void renderScene(LPVOID lpParam)
{
	// Typecast lpParam to COpenGLControl pointer
	COpenGLControl* oglControl = (COpenGLControl*)lpParam;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	spDirectionalLight.useProgram();
	
	spDirectionalLight.setUniform("projectionMatrix", oglControl->getProjectionMatrix());

	glm::mat4 mModelView = cCamera.look();
	glm::mat4 mModelToCamera = glm::mat4(1.0);

	spDirectionalLight.setUniform("PureColor", 1);
	glBindVertexArray(uiVAOs[0]);

	FOR(y, 3)
	{
		FOR(x, 3)
		{
			FOR(z, 3)
			{
				glm::mat4 mNewMatrix = glm::mat4(1.0);
				mNewMatrix = glm::translate(mNewMatrix, glm::vec3(0, 20, 0));
				if(bRotatingWall[FRONT] && z == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, 0, -1));
				if(bRotatingWall[BACK] && z == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, 0, -1));
				if(bRotatingWall[LEFT] && x == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(1, 0, 0));
				if(bRotatingWall[RIGHT] && x == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(1, 0, 0));
				if(bRotatingWall[TOP] && y == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, -1, 0));
				if(bRotatingWall[BOT] && y == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, -1, 0));
				glm::vec3 vSubcubePos = glm::vec3(-fSubcubeSize+fSubcubeSize*x, fSubcubeSize-fSubcubeSize*y, -fSubcubeSize+fSubcubeSize*z);
				mNewMatrix = glm::translate(mNewMatrix, vSubcubePos);

				mNewMatrix = glm::scale(mNewMatrix, glm::vec3(fSubcubeSize*0.97f, fSubcubeSize*0.97f, fSubcubeSize*0.97f));

				// We need to transform normals properly, it's done by transpose of inverse matrix of rotations and scales
				spDirectionalLight.setUniform("normalMatrix", glm::transpose(glm::inverse(mNewMatrix)));
				spDirectionalLight.setUniform("modelViewMatrix", mModelView*mNewMatrix);

				spDirectionalLight.setUniform("vColor", glm::vec4(float(y)/255.0f, float(x)/255.0f, float(z)/255.0f, 1));
				glDrawArrays(GL_TRIANGLES, 0, 36);
			}
		}
	}

	if(Keys::onekey(VK_LEFT) || Keys::onekey('Q'))
	{
		if(iSelectedWall >= 0)
		{
			bRotatingWall[iSelectedWall] = true;
			//fRotatingAngle = 0.0;
			bClockwiseRotation = iSelectedWall%2 ? true : false;
			nyansgn = bClockwiseRotation ? 1 : -1;
		}
	}

	if(Keys::onekey(VK_RIGHT) || Keys::onekey('E'))
	{
		if(iSelectedWall >= 0)
		{
			bRotatingWall[iSelectedWall] = true;
			//fRotatingAngle = 0.0;
			bClockwiseRotation = iSelectedWall%2 ? false : true;
			nyansgn = bClockwiseRotation ? -1 : 1;
		}
		
	}

	if(Keys::onekey(VK_LBUTTON))
	{
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		POINT mp; GetCursorPos(&mp); ScreenToClient(appMain.hWnd, &mp);
		RECT rect; GetClientRect(appMain.hWnd, &rect); mp.y = rect.bottom-mp.y;
		BYTE bInfo[3];
		glReadPixels(mp.x, mp.y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, bInfo);

		int y = bInfo[0];
		int x = bInfo[1];
		int z = bInfo[2];
		if(x >= 0 && x < 3 && y  >= 0 && y < 3 && z >= 0 && z < 3 && !bRotatingWall[0] && !bRotatingWall[1] && !bRotatingWall[2] && !bRotatingWall[3] && !bRotatingWall[4] && !bRotatingWall[5])
		{
			int iClickedCube = PackIndices(y, x, z);
			if(iClickedCube == iLastClickedCube)
				iSelectedWallIndex = (iSelectedWallIndex+1)%ESZ(CubeWalls[y][x][z]);
			else
				iSelectedWallIndex = 0;
			iLastClickedCube = iClickedCube;
			iSelectedWall = CubeWalls[y][x][z][iSelectedWallIndex];

			char data[222]; sprintf(data, "CC:  %d IND: %d WALL: %d Y: %d, X: %d, Z: %d",iClickedCube, iSelectedWallIndex, iSelectedWall, y, x, z);
			//SetWindowText(appMain.hWnd, data);
		}
	}

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	spDirectionalLight.setUniform("PureColor", 0);
	spDirectionalLight.setUniform("gSampler", 0);
	spDirectionalLight.setUniform("vColor", glm::vec4(1, 1, 1, 1));
	spDirectionalLight.setUniform("texCoordRotAngle", 0.0f);

	spDirectionalLight.setUniform("modelViewMatrix", glm::translate(mModelView, cCamera.vEye));
	sbMainSkybox.renderSkybox();

	glBindVertexArray(uiVAOs[0]);
	spDirectionalLight.setUniform("modelViewMatrix", &mModelView);
	
	// Render ground

	
	tTextures[0].bindTexture();
	glDrawArrays(GL_TRIANGLES, 36, 6);

	FOR(y, 3)
	{
		FOR(x, 3)
		{
			FOR(z, 3)
			{
				glm::mat4 mNewMatrix = glm::mat4(1.0);
				mNewMatrix = glm::translate(mNewMatrix, glm::vec3(0, 20, 0));
				if(bRotatingWall[FRONT] && z == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, 0, -1));
				if(bRotatingWall[BACK] && z == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, 0, -1));
				if(bRotatingWall[LEFT] && x == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(1, 0, 0));
				if(bRotatingWall[RIGHT] && x == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(1, 0, 0));
				if(bRotatingWall[TOP] && y == 0)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, -1, 0));
				if(bRotatingWall[BOT] && y == 2)mNewMatrix = glm::rotate(mNewMatrix, fRotatingAngle, glm::vec3(0, -1, 0));
				glm::vec3 vSubcubePos = glm::vec3(-fSubcubeSize+fSubcubeSize*x, fSubcubeSize-fSubcubeSize*y, -fSubcubeSize+fSubcubeSize*z);
				mNewMatrix = glm::translate(mNewMatrix, vSubcubePos);

				mNewMatrix = glm::scale(mNewMatrix, glm::vec3(fSubcubeSize*0.97f, fSubcubeSize*0.97f, fSubcubeSize*0.97f));

				// We need to transform normals properly, it's done by transpose of inverse matrix of rotations and scales
				spDirectionalLight.setUniform("normalMatrix", glm::transpose(glm::inverse(mNewMatrix)));
				spDirectionalLight.setUniform("modelViewMatrix", mModelView*mNewMatrix);
				
				FOR(k, 6)
				{
					glm::vec4 vColor = bMatchedColors ? vRubikColors[subCubes[y][x][z].iSideColors[k]] : subCubes[y][x][z].vRealColor[k];
					if(ShouldHighLight(iSelectedWall, y, x, z))
					{

						spDirectionalLight.setUniform("texCoordRotAngle", nyansgn*fRotatingAngle*3.1415535926f/180.0f);
						tTextures[2].bindTexture();
					}
					else
					{
						spDirectionalLight.setUniform("texCoordRotAngle", 0.0f);
						tTextures[1].bindTexture();
					}
					spDirectionalLight.setUniform("vColor", vColor);
					glDrawArrays(GL_TRIANGLES, k*6, 6);
				}
			}
		}
	}
	bool bOneRotating = false; FOR(k, 6)if(bRotatingWall[k])bOneRotating = true;
	if(bOneRotating)fRotatingAngle += appMain.sof(bClockwiseRotation ? 120.0f : -120.0f);
	if(abs(fRotatingAngle) > 90.0f)
	{
		if(bRotatingWall[FRONT])
		{
			int iIndices[] = {PackIndices(0, 0, 2), PackIndices(0, 1, 2), PackIndices(0, 2, 2),
				PackIndices(1, 0, 2), PackIndices(1, 1, 2), PackIndices(1, 2, 2),
				PackIndices(2, 0, 2), PackIndices(2, 1, 2), PackIndices(2, 2, 2)};
			RotateWall(iIndices, bClockwiseRotation, 0);
		}
		if(bRotatingWall[BACK])
		{
			int iIndices[] = {PackIndices(0, 0, 0), PackIndices(0, 1, 0), PackIndices(0, 2, 0),
				PackIndices(1, 0, 0), PackIndices(1, 1, 0), PackIndices(1, 2, 0),
				PackIndices(2, 0, 0), PackIndices(2, 1, 0), PackIndices(2, 2, 0)};
			RotateWall(iIndices, bClockwiseRotation, 0);
		}
		if(bRotatingWall[LEFT])
		{
			int iIndices[] = {PackIndices(0, 0, 0), PackIndices(0, 0, 1), PackIndices(0, 0, 2),
				PackIndices(1, 0, 0), PackIndices(1, 0, 1), PackIndices(1, 0, 2),
				PackIndices(2, 0, 0), PackIndices(2, 0, 1), PackIndices(2, 0, 2)};
			RotateWall(iIndices, bClockwiseRotation, 1);
		}
		if(bRotatingWall[RIGHT])
		{
			int iIndices[] = {PackIndices(0, 2, 0), PackIndices(0, 2, 1), PackIndices(0, 2, 2),
				PackIndices(1, 2, 0), PackIndices(1, 2, 1), PackIndices(1, 2, 2),
				PackIndices(2, 2, 0), PackIndices(2, 2, 1), PackIndices(2, 2, 2)};
			RotateWall(iIndices, bClockwiseRotation, 1);
		}
		if(bRotatingWall[TOP])
		{
			int iIndices[] = {PackIndices(0, 0, 0), PackIndices(0, 1, 0), PackIndices(0, 2, 0),
				PackIndices(0, 0, 1), PackIndices(0, 1, 1), PackIndices(0, 2, 1),
				PackIndices(0, 0, 2), PackIndices(0, 1, 2), PackIndices(0, 2, 2)};
			RotateWall(iIndices, bClockwiseRotation, 2);
		}
		if(bRotatingWall[BOT])
		{
			int iIndices[] = {PackIndices(2, 0, 0), PackIndices(2, 1, 0), PackIndices(2, 2, 0),
				PackIndices(2, 0, 1), PackIndices(2, 1, 1), PackIndices(2, 2, 1),
				PackIndices(2, 0, 2), PackIndices(2, 1, 2), PackIndices(2, 2, 2)};
			RotateWall(iIndices, bClockwiseRotation, 2);
		}
		FOR(k, 6)bRotatingWall[k] = false;
		fRotatingAngle = 0.0f;
	}
	static bool bUpdate = true;
	if(bUpdate)
		cCamera.update();
	if(Keys::onekey('U'))bUpdate = !bUpdate;
	if(Keys::onekey('C'))bMatchedColors = !bMatchedColors;

	// Print something over scene

	spFont2D.useProgram();
	glDisable(GL_DEPTH_TEST);
	spFont2D.setUniform("projectionMatrix", oglControl->getOrthoMatrix());
	spFont2D.setUniform("vColor", glm::vec4(1.0f, 1.0f, 1.0f, 1.0f));

	RECT rect; GetClientRect(appMain.hWnd, &rect);
	char sFormat[255]; sprintf(sFormat, "Using: %s colors ('C' to toggle)", bMatchedColors ? "matched" : "original");
	ftFont.print(sFormat, 12, rect.bottom-30, 16);

	glEnable(GL_DEPTH_TEST);
	if(Keys::onekey(VK_ESCAPE))PostQuitMessage(0);




	oglControl->swapBuffers();
}

/*-----------------------------------------------

Name:	releaseScene

Params:	lpParam - Pointer to anything you want.

Result:	Releases OpenGL scene.

/*---------------------------------------------*/

void releaseScene(LPVOID lpParam)
{
	FOR(i, NUMTEXTURES)tTextures[i].releaseTexture();
	sbMainSkybox.releaseSkybox();

	spDirectionalLight.deleteProgram();
	spOrtho2D.deleteProgram();
	spFont2D.deleteProgram();
	FOR(i, 4)shShaders[i].deleteShader();
	ftFont.releaseFont();

	glDeleteVertexArrays(1, uiVAOs);
	vboSceneObjects.releaseVBO();
}