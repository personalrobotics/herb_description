^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package herb_description
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

2.0.0 (2016-05-11)
------------------
* Fixed the position of the head `#24 <https://github.com/personalrobotics/herb_description/issues/24>`_ `#25 <https://github.com/personalrobotics/herb_description/issues/25>`_
* Contributors: Clint Liddick, Michael Koval

1.4.0 (2016-05-11)
------------------
* Switched to inertial properties from version AC-02 of Barrett's datasheet `#22 <https://github.com/personalrobotics/herb_description/issues/22>`_
* Add higher-resolution collision geometry group for grippers in a `<geometry_group>` tag. `#21 <https://github.com/personalrobotics/herb_description/issues/21>`_
* Removed support for rosbuild. `#20 <https://github.com/personalrobotics/herb_description/issues/20>`_
* Added explicit link for the force/torque sensor.
* Change all line-endings from Windows to Unix.
* Contributors: Clint Liddick, David Butterworth, Michael Koval

1.3.0 (2015-10-12)
------------------
* Changing joint limits to match those hardcoded in OWD (`#18 <https://github.com/personalrobotics/herb_description/issues/18>`_
* Improved Kinect 2 extrinsics (`#15 <https://github.com/personalrobotics/herb_description/issues/15>`_)
* Add skeleton tracker transform (`#14 <https://github.com/personalrobotics/herb_description/issues/14>`_)
* Fixed orientation of kinect2_link for the new version of iai_kinect (`#13 <https://github.com/personalrobotics/herb_description/issues/13>`)
* Added static transforms to the URDF (`#12 <https://github.com/personalrobotics/herb_description/issues/12>`_)
* Added missing disable_collision pairs
* Contributors: Aaron Walsman, Clint Liddick, Jennifer King, Michael Koval, Shushman

1.2.0 (2015-05-01)
------------------
* Adding link adjacencies
* Force the head joints to be revolute.
  These were exported from SolidWorks as CONTINUOUS.
* Contributors: Jennifer King, Michael Koval

1.1.0 (2015-03-30)
------------------
* Changed head velocity limits to match OWD/Pantilt.
* Adding notes on visual geometry.
* Adding adjacency between herb-base and head/wam2
* Converted head_wam2_collision to binary STL format
* Added missing link from the head manipulator group.
* Contributors: Aaron Walsman, Jennifer King, Michael Koval

1.0.1 (2014-10-10)
------------------

1.0.0 (2014-08-25)
------------------
* Set COLLADA ambiant lighting to (0, 0, 0, 1).
* Fixed units on the new DAE meshes.
* Colors
* Removed install() of non-existant ordata directory.
* Added auto-generated disable_collision tags.
* Updated WAM and head transforms for HERB 2.5.
  Thanks to Michael Dawson-Haggerty for exporting the new measurements from
  SolidWorks and verifying their accuracy on the real hardware.
* Added the new HERB model.
* Switched all fingers to DAE models.
* Fixed COLLADA units for groovy+ RViz.
* Generate a KinBody XML file in fuerte.
* Ignore auto-generated files.
* Merge branch 'master' of github.com:personalrobotics/herb_description
  Conflicts:
  CMakeLists.txt
* Added missing dependencies.
* Trying to clean up dependencies.
* Removed auto-generated file.
* Fixed the broken herb_base collision mesh.
  This collision was crashing RViz in Hydro. I imported the mesh into
  Blender and re-exported it. This seems to have fixed things.
* Removed launchfile.
* Removed fuerte manifest.
* Removed OpenRAVE model wrappers.
* Created more standalone models.
* Generate a valid SRDF file.
* Removed or_urdf references.
* Changed Z_UP to Y_UP in COLLADA files for qtcoin.
* Changed several build_depend to buildtool_depend
* Removed old urdf_to_openrave macro.
* adding more adjacency links (all pairwise finger combinations and wam4/wam6 and wam4/wam7
* set wam4 adjacent to wam7 for both arms
* Catkin version looks good, just using wrong paths.
* Cleaning up CMakeLists.
* Added OPENRAVE_PLUGINS path hack.
* Depend on rosbash for the rosrun command.
* Fixed some race conditions. Added another.
* Added missing rosdeps.
* Updated package.xml and CMakeLists.txt to support catkinized builds.
* adding textures
* Generate a DAE file. Fixed joint limits.
* modified for the new Herb base (rack-mount cpus)
* Successfully generated a URDF.
* Generate all URDF files in CMakeLists.
* Catkinizing the build process.
* Trying to convert to CMakeLists for Catkin.
* Fixed an incorrect (and huge) link mass on BH280.
* Awesome new DAE files (thanks to Aaron).
* added hand_base and re-ran on all meshes
* fixed random giant triangles, vertex normals probably still backwards
* initial collada/smooth shading conversion
* Fixed a bogus wam1 x wam3 self-collision.
* Added release tag.
* Fixed the axis of the finger spread joint.
* Adding adjacency links for head
* Fixed HERB's tilt axis.
* sphere update
* new sphere locations
* adding collision meshes
* added adjacency link between left and right wam1 to avoid collisions on new low-res geometry
* Collision primitives for herb model. These are not used yet.
* wam0.STL
* removing unused stl files
* removing unused stl files
* collision meshes
* Adding collision meshes
* added robot_state_publisher
* Adding robot for standalone hand
* Build an OpenRAVE model of the BH280.
* Fixing reference to wam_base so chomp won't seg fault
* Updated to the latest meshes from Mike1.
* Adding urdf config file for properly ordering joints and defining adjacent links
* Moved adjacencies from robot.xml to kinbody.xml
* Added missing adjacent links.
* Added CHOMP spheres and adjacent link specifications.
* Fixed the spread joint on the BH280.
* Fixing mimic joints
* Updated model
* Fixing manifest to set ordata path correctly
* Updating herb.robot.xml
* Fixed a bug in the makefile.
* Removed rosrun reference.
* Added the SRDF file to the Makefile.
* Fixed the static transform publishers in display.launch.
* Changed the order of the manipulators.
* Fixed the BH model.
* Added joint limits and stuff.
* Added SRDF file.
* Renamed template URDF files.
* Added joint limits and inertial properties to template files.
* Added OpenRAVE robot wrapper.
* Fixed makefile.
* Autogenerate an OpenRAVE KinBody.
* Added the HERB model.
* Launchfile to visualize the URDF in RViz.
* Added the herb_base export.
* Partial HERB model including his arms and hands.
* Added the BH280 model.
* Added a manifest and ignore the temporary file.
* Added a standalone WAM URDF model.
* URDF description of HERB.
* Contributors: Aaron Walsman, Anca Dragan, Jennifer King, Joshua Haustein, Michael Dawson-Haggerty, Michael Koval, Mike Koval, Prasanna Velagapudi
