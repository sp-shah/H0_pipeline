##############################
Title: Pipeline Descripttion
Author: Shivani Shah, 
Created around: 07/12/20
Last update: 09/01/21
Note: Check all paths!!
############################



1. hod 
   - hod from: https://github.com/amjsmith/hodpy 
   - creates input file for hod and runs hod
   - input file created by running hod/mydir/code/create_input.py 
   - input file for hod saved in hod/mydir/data/resolution/rundirName/optionalLinkingLength/snapshot_input_sim1.hdf5
   - to implement the hod, check for optimal input paths, box-size etc. in hod/parameters.py
   - modify for appropriate output path in hod/make_catalogue_snapshot.py 
   - run hod by executng hod/make_catalogue_snapshot.py
   - currently, output file saved in hod/output/resolution/rundirName/optionalLinkingLength/cat_snapshot_observed.hdf5



2. myhod_wrapper
   - modifies the peculiar velocity, position of the galaxies added by hod. I believe this was done to retain the constrained 
     velocity and position information of the AREPO catalog.
   - run mock_cat0.py or mock_cat1.py (only difference between the two are the paths)
   - check for input and output path in the function definition main()
   - best way to run them is using sbatch.sh (mock_cat0.py) or sbatch1.sh (mock_cat1.py) --> can take 1-2 days
   - data saved in the appropriate myhod_wrappr/data/...../mock_cat.hdf5 or however you save it 



3. periodicBox
   - creates a periodic box, modify coordinate system, add ra, dec, l,b, 
     add r band magnitude, magnitude cutoff, corrects recessional velocity for 
     appropriate distance estimates
   - check function defintion main() in periodicBox/create_per_boxes.py for details 
   - needs funcdef.py and values.py to run 
   - modify input file path in main() of create_per_boxes.py
   - if needed modify output file path too
   - run with "python create_per_boxes.py" on interactive node with 200gb memory
   - final output saved as periodic_box_wvelcorr.hdf5


4. Grouping Algorithm
   - type "module load idl"
   - type "idl" in the terminal. Once the interface is initialized follow the next steps
   - compile the following scripts from within crookAlg/code
     .run libraries/angsep.pro
     .run libraries/removeduplicate.pro
     .run libraries/wheresize.pro
     .run libraries/numinrange.pro
     .run libraries/findvalue.pro
     .run libraries/renumbergroups.pro
   - to run the algorithm: .run run_percolation_simdata (this script is created by S.S.)
   - output saved in ../data/resolution/rundirName/optionalLinkingLength/groupGal.hdf5
   - the code was provided to me by Aidan Crook and Lucas Macri. Maybe acknowledge them in the paper? 


5. Analysis
   - refines the catalog for single galaxies, add group mass, halo mass, matching halo index, 
     no. of halo members, number of group members, interloper ratio, completion ratio of the group
   - specific results to show? See the google slides and the analysis report
   - 
