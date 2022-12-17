#include <iostream>
#include <vector>
#include <algorithm>
#include <random>
#include <cmath>
#include <fstream>
#include <limits>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/copy.h>
#include <thrust/random.h>
#include <thrust/transform.h>
// #include <thrust/iterator/counting_iterator.h>
#include <thrust/functional.h>
#include <thrust/for_each.h>
#include <thrust/sequence.h>


// Dimensions of surfaces (lengths)
constexpr double X = 1;
constexpr double Y = 1;
constexpr double Z = 2;

// Number of trials and points
constexpr int trials = (int)5e3;
constexpr int N = (int)1e5;

double sdCalc(float mean, thrust::host_vector<float> data);

void writeCSV(thrust::host_vector<float> data);

struct integral_functor : public thrust::unary_function<float,float>
{
    __host__ __device__
    float operator()(int the_seed) {

        // seed a random number generator
        thrust::default_random_engine rng(the_seed);
        // create a mapping from random numbers to [0,1)
        thrust::uniform_real_distribution<float> dist(0,1);

        float x, yh, theta, phi, dy, yv, z;
        int hits = 0;

        for (int i=0; i < N; i++) {
            // random values on a horizontal surface
            x = dist(rng) * X;
            yh = dist(rng) * Y;
            theta = acosf(1 - 2 * dist(rng)) / 2.0;
            phi = dist(rng) * M_PI - M_PI/2.0;

            // points on a vertical plane
            dy = x * tanf(phi);
            yv = yh + dy;
            z = sqrtf(x*x + dy*dy) * tanf(M_PI/2.0 - theta);

            // see if there's a hit
            if (z > 0 && z < Z && yv > 0 && yv < Y)
                hits += 1;
        }
 
        return ((float)hits)/(2.0 * (float)N);
    }
};

int main() {

    thrust::host_vector<int> rvec(trials);
    thrust::device_vector<float> vf_dev(trials);

    // make seeds
    thrust::default_random_engine rng(time(NULL));
    thrust::uniform_int_distribution<int> dist {0, std::numeric_limits<int>::max()};
    thrust::generate(rvec.begin(), rvec.end(), [&] { return dist(rng); });

    // copy to device and perform MC
    thrust::device_vector<float> rvec_dev = rvec;
    thrust::transform(rvec_dev.begin(), rvec_dev.end(), vf_dev.begin(), integral_functor());

    // copy back to host
    thrust::host_vector<float> vf = vf_dev;

    float mu = thrust::reduce(vf.begin(), vf.end()) / ((float)vf.size());
    double sigma = sdCalc(mu, vf);
    double se = sigma / sqrtf((float) trials);

    std::cout << "mu " << mu << "\nsigma " << sigma << "\nse " << se << std::endl;

    writeCSV(vf);
    
}

// standard deviation
double sdCalc(float mean, thrust::host_vector<float> data) {
    double ret = 0.0;
    for (int i=0; i < data.size(); i++)
        ret += pow(data[i] - mean, 2);
    
    return sqrt(ret / ((double) data.size()));
}

void writeCSV(thrust::host_vector<float> data) {
    std::ofstream outfile("./out.csv");
    for (int i=0; i < data.size(); i++) {
        outfile << i << ", " << data[i] << "\n";
    }
    outfile.close();
    std::ofstream vffile("./vf.csv");
    for (int i=0; i < data.size(); i++) {
        vffile << data[i] << "\n";
    }
    vffile.close();
}