# Website: https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer
# MIT License

# Copyright (c) 2023 PiCode9560

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node


class_name MeshSlicer



var vert_slice = []

var mdt = MeshDataTool.new() 



func _convertToArrayMesh(mesh:Mesh):
	var surface_tool := SurfaceTool.new()
	var new_mesh = ArrayMesh.new()
	for i in range(mesh.get_surface_count()):
		surface_tool.create_from(mesh,i)
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface_tool.commit().surface_get_arrays(0))
		new_mesh.surface_set_material(i,mesh.surface_get_material(i))
	return new_mesh




##Slice a mesh in half using Transform3D as the local position and direction. Return an array of the sliced meshes. The cross-section material is positioned and rotated base on the Transform3D
func slice_mesh(slice_transform:Transform3D,mesh:Mesh,cross_section_material:Material = null) -> Array:
	mesh = _convertToArrayMesh(mesh)
	
	var normal = -slice_transform.basis.z
	var at = slice_transform.origin
	
	var surfaces1 = []
	var surfaces_mat1 = []	
	var surface_tool1_2 := SurfaceTool.new()
	surface_tool1_2.begin(Mesh.PRIMITIVE_TRIANGLES)
	var surfaces2 = []
	var surfaces_mat2 = []
	var surface_tool2_2 := SurfaceTool.new()
	surface_tool2_2.begin(Mesh.PRIMITIVE_TRIANGLES)
	vert_slice.clear()
	
	if cross_section_material == null:
		if mesh.get_surface_count() != 0:
			cross_section_material = mesh.surface_get_material(0)
	for surface_idx in range(mesh.get_surface_count()):
		mdt.create_from_surface(mesh, surface_idx)
		
		var surface_tool := SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		var surface_tool2 := SurfaceTool.new()
		surface_tool2.begin(Mesh.PRIMITIVE_TRIANGLES)
		var verts_side = []
		var edge_slice = {}
		var material = mesh.surface_get_material(surface_idx)

		
		for vert in range(mdt.get_vertex_count()):
			var v1 = mdt.get_vertex(vert)
			var side = _check_side(v1,normal,at)
			verts_side.append(side)


		for edge in range(mdt.get_edge_count()):
			var v1 = mdt.get_edge_vertex(edge,0)
			var v2 = mdt.get_edge_vertex(edge,1)
			var v1_at = mdt.get_vertex(v1)
			var v2_at = mdt.get_vertex(v2)
			if verts_side[v1] != verts_side[v2] and verts_side[v2] != 0 and verts_side[v1] != 0:
				var intersect = _line_plane_intersection(v1_at,v2_at,at,normal)
				if intersect != null:
					if intersect != v2_at and intersect != v1_at:
						var norm = mdt.get_vertex_normal(v2)
						var uv = mdt.get_vertex_uv(v1) + (mdt.get_vertex_uv(v2)-mdt.get_vertex_uv(v1))*(v1_at.distance_to(intersect)/v1_at.distance_to(v2_at))

						edge_slice[edge] = [intersect,norm,uv]
		for face in range(mdt.get_face_count()):


			var face_verts1 = []
			var face_verts2 = []
			var edge_intersect = []
			for e in range(3):
				if edge_slice.has(mdt.get_face_edge(face,e)):
					edge_intersect.append(e)
			if len(edge_intersect) == 0:
				var v1 = mdt.get_face_vertex(face,0)
				var v2 = mdt.get_face_vertex(face,1)
				var v3 = mdt.get_face_vertex(face,2)
				for v in range(3):
					var vv1 = mdt.get_vertex(mdt.get_face_vertex(face,v))
					var vv2 = mdt.get_vertex(mdt.get_face_vertex(face,(v+1)%3))
					if _check_side(vv1,normal,at) == 0 and _check_side(vv2,normal,at) == 0:
						_add_to_vert_slice(mdt.get_face_vertex(face,v),mdt.get_face_vertex(face,(v+1)%3))
						break
				if verts_side[v1] + verts_side[v2] + verts_side[v3] > 0:
					face_verts1.append(v1)
					face_verts1.append(v2)
					face_verts1.append(v3)
				else:
					face_verts2.append(v1)
					face_verts2.append(v2)
					face_verts2.append(v3)
					
			elif  len(edge_intersect) == 1:
				var v1 = null
				var v2 = mdt.get_edge_vertex(mdt.get_face_edge(face, edge_intersect[0]),0)
				var v3 = edge_slice[mdt.get_face_edge(face, edge_intersect[0])]
				var v4 = mdt.get_edge_vertex(mdt.get_face_edge(face, edge_intersect[0]),1)
				for vert in range(3):
					var nv = mdt.get_face_vertex(face,vert)
					if nv != v2 and nv != v4:
						v1 = nv
						v2 = mdt.get_face_vertex(face,(vert+1)%3)
						v4 = mdt.get_face_vertex(face,(vert+2)%3)
						break
									
				_add_to_vert_slice(v1,v3)
				if verts_side[v2] == 1:
					face_verts1.append(v1)
					face_verts1.append(v2)
					face_verts1.append(v3)
					face_verts2.append(v1)
					face_verts2.append(v3)
					face_verts2.append(v4)
				else:
					face_verts2.append(v1)
					face_verts2.append(v2)
					face_verts2.append(v3)
					face_verts1.append(v1)
					face_verts1.append(v3)
					face_verts1.append(v4)
						

			elif  len(edge_intersect) == 2:
				var e1 = mdt.get_face_edge(face,edge_intersect[0])
				var e2 = mdt.get_face_edge(face,edge_intersect[1])
				var v1 = null
				var v2 = edge_slice[e2]
				var v3 = null
				var v4 = null
				var v5 = edge_slice[e1]
				var e1v1 = mdt.get_edge_vertex(e1,0)
				var e1v2 = mdt.get_edge_vertex(e1,1)
				var e2v1 = mdt.get_edge_vertex(e2,0)
				var e2v2 = mdt.get_edge_vertex(e2,1)
				for vert in range(3):
					var cv1 = mdt.get_face_vertex(face,vert)
					var cv2 = mdt.get_face_vertex(face,(vert+1)%3)
					if (cv1 == e1v1 or cv1 == e1v2) and (cv1 == e2v1 or cv1 == e2v2):
						v1 = mdt.get_face_vertex(face,vert)
						v3 = mdt.get_face_vertex(face,(vert+1)%3)
						v4 = mdt.get_face_vertex(face,(vert+2)%3)
						if (cv2 == e1v1 or cv2 == e1v2):
							v2 = edge_slice[e1]
							v5 = edge_slice[e2]
						break
				_add_to_vert_slice(v2,v5)


				if verts_side[v1] == 1:
					face_verts1.append(v1)
					face_verts1.append(v2)
					face_verts1.append(v5)
					face_verts2.append(v2)
					face_verts2.append(v3)
					face_verts2.append(v5)
					face_verts2.append(v3)
					face_verts2.append(v4)
					face_verts2.append(v5)
				if verts_side[v1] == -1:
					face_verts2.append(v1)
					face_verts2.append(v2)
					face_verts2.append(v5)
					face_verts1.append(v2)
					face_verts1.append(v3)
					face_verts1.append(v5)
					face_verts1.append(v3)
					face_verts1.append(v4)
					face_verts1.append(v5)
			for v in face_verts1:
				var vert = v
				var uv = Vector2.ZERO
				var norm = Vector3.ZERO
				if typeof(v) == TYPE_INT:
					vert = mdt.get_vertex(v)
					norm = mdt.get_vertex_normal(v)
					uv = mdt.get_vertex_uv(v)
				if typeof(v) == TYPE_ARRAY:
					vert = v[0]
					norm = v[1].normalized()
					uv = v[2]
				surface_tool.set_normal(norm)
				surface_tool.set_uv(uv)
				surface_tool.add_vertex(vert)

				
					
			for v in face_verts2:
				var vert = v
				var uv = Vector2.ZERO
				var norm = Vector3.ZERO	
				if typeof(v) == TYPE_INT:
					vert = mdt.get_vertex(v)
					norm = mdt.get_vertex_normal(v)
					uv = mdt.get_vertex_uv(v)
				if typeof(v) == TYPE_ARRAY:
					vert = v[0]
					norm = v[1].normalized()
					uv = v[2]
				surface_tool2.set_normal(norm)
				surface_tool2.set_uv(uv)
				surface_tool2.add_vertex(vert)
				
		surfaces1.append(surface_tool.commit())
		surfaces_mat1.append(material)
		surfaces2.append(surface_tool2.commit())
		surfaces_mat2.append(material)

	



	var sorted_verts = _sort_verts()
	

	sorted_verts = _set_holes(sorted_verts,normal,slice_transform)

	
	
	

	for polygon in sorted_verts:
		var new_polygon = PackedVector2Array()

		for vert in polygon:
			var local = _to_transform_local(slice_transform,vert)
			new_polygon.append(Vector2(local.z,local.y))
		var triangulate = Geometry2D.triangulate_polygon(new_polygon)
		for v in range(len(triangulate)/3):
			
			
			var vert1 = polygon[triangulate[v*3]]
			var vert2 = polygon[(triangulate[v*3+1])%len(triangulate)]
			var vert3 = polygon[(triangulate[v*3+2])%len(triangulate)]
			
			if _check_side(_get_triangle_normal(vert1,vert2,vert3),normal,Vector3.ZERO) != -1:
				surface_tool1_2.set_uv(_get_uv(slice_transform,vert1))
				surface_tool1_2.add_vertex(vert1)
				surface_tool1_2.set_uv(_get_uv(slice_transform,vert2))
				surface_tool1_2.add_vertex(vert2)
				surface_tool1_2.set_uv(_get_uv(slice_transform,vert3))
				surface_tool1_2.add_vertex(vert3)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert3))
				surface_tool2_2.add_vertex(vert3)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert2))
				surface_tool2_2.add_vertex(vert2)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert1))
				surface_tool2_2.add_vertex(vert1)
			else:

				surface_tool1_2.set_uv(_get_uv(slice_transform,vert3))
				surface_tool1_2.add_vertex(vert3)
				surface_tool1_2.set_uv(_get_uv(slice_transform,vert2))
				surface_tool1_2.add_vertex(vert2)
				surface_tool1_2.set_uv(_get_uv(slice_transform,vert1))
				surface_tool1_2.add_vertex(vert1)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert1))
				surface_tool2_2.add_vertex(vert1)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert2))
				surface_tool2_2.add_vertex(vert2)
				surface_tool2_2.set_uv(_get_uv(slice_transform,vert3))
				surface_tool2_2.add_vertex(vert3)
							


	surface_tool1_2.generate_normals()
	surface_tool2_2.generate_normals()
	surfaces1.append(surface_tool1_2.commit())
	surfaces2.append(surface_tool2_2.commit())
	surfaces_mat1.append(cross_section_material)
	surfaces_mat2.append(cross_section_material)
	var new_mesh = ArrayMesh.new()

	
	for i in range(0,len(surfaces1)):
		if surfaces1[i].get_surface_count() != 0:
			new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surfaces1[i].surface_get_arrays(0))
			new_mesh.surface_set_material(new_mesh.get_surface_count()-1,surfaces_mat1[i])
			
		
	var new_mesh2 = ArrayMesh.new()

	
	for i in range(0,len(surfaces2)):
		if surfaces2[i].get_surface_count() != 0:
			new_mesh2.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surfaces2[i].surface_get_arrays(0))
			new_mesh2.surface_set_material(new_mesh2.get_surface_count()-1,surfaces_mat2[i])
			
		
	
	

	return[new_mesh,new_mesh2]
	

func _set_holes(polygons,norm,slice_transform):
	if len(polygons) <= 1:
		return polygons
	else:
		var closest_point = Vector2.ZERO
		for i in range(len(polygons)):
			
			
			var polygon = polygons[i]
			

			if len(polygon) > 0:
				
				var nearest_intersect_dist = INF
				var nearest_intersect_polygon = -1
				var point = _to_transform_local2(slice_transform,polygon[0])
				point = Vector2(point.x,point.y)
				var is_inside = false
				
				for j in range(len(polygons)):
			
					var check_dir = Vector3.ZERO
					if j != i:
						

						var polygon_check = polygons[j]

						
						var polygon2d = []

						
						var closest_dist = INF
						for k in range(len(polygon_check)):
							var local_pos = _to_transform_local2(slice_transform,polygon_check[k])
							var pos2d = Vector2(local_pos.x,local_pos.y)
							local_pos = _to_transform_local2(slice_transform,polygon_check[(k+1)%len(polygon_check)])
							var pos2d2 = Vector2(local_pos.x,local_pos.y)
							polygon2d.append(pos2d)
							
							var point_segment = Geometry2D.get_closest_point_to_segment(point,pos2d,pos2d2)
							if point_segment.distance_to(point) < closest_dist:
								closest_dist = point_segment.distance_to(point)
								closest_point = point_segment
							
						if Geometry2D.is_point_in_polygon(point,PackedVector2Array(polygon2d)) == true:
							is_inside = true
							if closest_dist < nearest_intersect_dist:
								nearest_intersect_dist = closest_dist
								nearest_intersect_polygon = j
								
						


				if is_inside:
					var polygon_to = polygons[nearest_intersect_polygon]
					var polygon_to2 = polygons[nearest_intersect_polygon]
					var polygon_index = -1
					var connected = false

					while not connected:
						if polygon_index >= len(polygons):

							break
						if (polygon_to2 == polygon_to and polygon_index != -1) or polygon_index-1 == i:
							polygon_to = polygons[polygon_index] 
							polygon_index += 1
							continue


						for j in range(len(polygon)):
							var vert = polygon[j]
							

							for l in range(len(polygon_to)):
								var is_intersect = false
								var vert_to = polygon_to[l]
								var vert_up = vert+norm
								var n = _get_triangle_normal(vert,vert_to,vert_up)

								
								for k in range(len(polygons)):
									
									var polygon_check = polygons[k]
									for m in range(len(polygon_check)):
										var v1 = polygon_check[m]
										var v2 = polygon_check[(m+1)%len(polygon_check)]
										if v1 != vert_to and v1 != vert and v2 != vert_to and v2 != vert:
											var intersect = _line_plane_intersection(v1,v2,vert,n)
											if intersect != null:

												if _check_side(intersect,(vert_to-vert).normalized(),vert) < 0:
													if _check_side(intersect,(vert-vert_to).normalized(),vert_to) < 0:
														is_intersect = true
														break

									if is_intersect:
										break
								if not is_intersect:


									var connection_norm = _get_triangle_normal(polygon[j],polygon_to[l],polygon_to[l]+norm)
									var e_norm = _get_triangle_normal(polygon_to[(l+1)%len(polygon_to)],polygon_to[l],polygon_to[l]+norm)
									var e_norm2 = _get_triangle_normal(polygon_to[posmod(l-1,len(polygon_to))],polygon_to[l],polygon_to[l]+norm)
									if _find_closest_edge(e_norm2,e_norm,connection_norm,polygon_to[posmod(l-1,len(polygon_to))],polygon_to[(l+1)%len(polygon_to)],polygon[j]) == 1:
										connection_norm = - connection_norm
									e_norm = _get_triangle_normal(polygon[j],polygon[posmod((j-1),len(polygon))],polygon[j]+norm)
									e_norm2 = _get_triangle_normal(polygon[j],polygon[posmod((j+1),len(polygon))],polygon[j]+norm)
									if _find_closest_edge(e_norm2,e_norm,connection_norm,polygon[posmod((j+1),len(polygon))],polygon[posmod((j-1),len(polygon))],polygon_to[l]) == 0:


										for k in range(len(polygon)):
											polygons[nearest_intersect_polygon].insert(l+1+k,polygons[i][(k+j)%len(polygon)])
									else:

										for k in range(0,len(polygon)):
											polygons[nearest_intersect_polygon].insert(posmod(l+1+k,len(polygons[nearest_intersect_polygon])),polygons[i][posmod(j-k,len(polygon))])
									polygons[nearest_intersect_polygon].insert(posmod(l+len(polygon)+1,len(polygons[nearest_intersect_polygon])),polygons[nearest_intersect_polygon][(l)%len(polygon_to)])
									polygons[nearest_intersect_polygon].insert(posmod(l+len(polygon)+1,len(polygons[nearest_intersect_polygon])),polygons[i][j%len(polygon)])


									connected = true
									break

							if connected:
								break
						if not connected:
							polygon_to = polygons[polygon_index] 
							polygon_index += 1
					if connected:
						polygons[i] = []
						
		return polygons
				

func _add_to_vert_slice(v1,v2):
	if typeof(v1) == TYPE_ARRAY:
		v1 = round(v1[0]*10000)/10000
	else:
		v1 = round(mdt.get_vertex(v1)*10000)/10000
	if typeof(v2) == TYPE_ARRAY:
		
		v2 = round(v2[0]*10000)/10000
	else:
		v2 = round(mdt.get_vertex(v2)*10000)/10000
	vert_slice.append([v1,v2])
		
func _find_closest_edge(norm1:Vector3,norm2:Vector3,norm_to:Vector3,vert1:Vector3,vert2:Vector3,vert_to:Vector3):
	var mid_point = (vert1+vert_to)/2

	var to_side = _check_side(mid_point,norm_to,vert_to)
	var side = _check_side(mid_point,norm1,vert1)
	if side != to_side:
		norm1 = -norm1
		side = -side
	
	mid_point = (vert2+vert_to)/2
	to_side = _check_side(mid_point,norm_to,vert_to)
	var side2 = _check_side(mid_point,norm2,vert2)
	if side2 != to_side:
		norm2 = -norm2
		side2 = - side2

	if side == side2:
		
		if side == -1:
			if (vert1-vert_to).length() < (vert2-vert_to).length():
				return 0
			else:
				return 1
		else:
			if (vert1-vert_to).length() < (vert2-vert_to).length():
				return 1
			else:
				return 0
	else:
		if side < side2:
			return 0
		else:
			return 1
func _sort_verts():


	var sorted_list = []
	var list_of_sorted_list = []


	while len(vert_slice) > 0:
		if len(sorted_list) == 0:
			var has = false
			for i in list_of_sorted_list:
				if _is_in_sorted_list(i,vert_slice[0][0]):
					has = true
				if _is_in_sorted_list(i,vert_slice[0][1]):
					has = true
			if not has:
				sorted_list.append([vert_slice[0][0],false,true])
				sorted_list.append([vert_slice[0][1],true,false])
				vert_slice.erase(vert_slice[0])
			else:
				vert_slice.erase(vert_slice[0])
				continue
			
			
				
		var v_count = len(vert_slice)
		var closed = false

		for i in vert_slice:
			if (not _is_in_sorted_list(sorted_list,i[1])) or (not _is_in_sorted_list(sorted_list,i[0])):
				for j in range(2):
					
					
					var l = [sorted_list[0],sorted_list[len(sorted_list)-1]][j]
					

					
					if l[1] == false or l[2] == false:
						if l[0] == i[0]:
							if not _is_in_sorted_list(sorted_list,i[1]):
								if l[1] == false:


									sorted_list[j][1] = true
									sorted_list.insert(j,[i[1],false,true])
									vert_slice.erase(i)

									break

						elif l[0] == i[1]:
							if not _is_in_sorted_list(sorted_list,i[0]):
								if l[1] == false:

									sorted_list[j][1] = true
									sorted_list.insert(j,[i[0],false,true])
									vert_slice.erase(i)

									break


			else:
				vert_slice.erase(i)
				
				
			if len(sorted_list) != 0:
				var srt = sorted_list[sorted_list.size()-1][0]

				var srt2 = sorted_list[0][0]

				if i[0] == srt2 and i[1] == srt:
					closed = true
					break
				if i[0] == srt2 and i[1] == srt:
					closed = true
					break
				if srt == srt2:
					closed = true
					break


		if closed:
			for i in range(len(sorted_list)):
				sorted_list[i] = sorted_list[i][0]
			list_of_sorted_list.append(sorted_list)
			sorted_list = []
		if v_count == len(vert_slice):

			sorted_list = []
	for i in range(len(sorted_list)):
		sorted_list[i] = sorted_list[i][0]
	list_of_sorted_list.append(sorted_list)
	return list_of_sorted_list
	
	
func _get_triangle_normal(p1:Vector3,p2:Vector3,p3:Vector3):
	return -Plane(p1,p2,p3).normal

func _is_in_sorted_list(sorted_list,value):
	return sorted_list.has(value)






func _check_side(point:Vector3,normal:Vector3,plane_at:Vector3):
	var relative_pos = plane_at - round(point*10000)/10000
	var dot = round(normal.dot(relative_pos)*10000)/10000
	return -sign(dot)


func _get_uv(ttransform: Transform3D, pos: Vector3) -> Vector2:
	var value = _to_transform_local2(ttransform,pos)
	return Vector2(value.x,value.y)
func _to_transform_local(Transform: Transform3D, global_pos: Vector3) -> Vector3:
	var xform := Transform.affine_inverse()
	return Vector3(
		xform.basis[0].dot(global_pos) + xform.origin.x,
		xform.basis[1].dot(global_pos) + xform.origin.y,
		xform.basis[2].dot(global_pos) + xform.origin.z
	)
		
func _to_transform_local2(Transform: Transform3D, global_pos: Vector3) -> Vector3:
	var xform := Transform.affine_inverse()
	return Vector3(
		Transform.basis[0].dot(global_pos) + xform.origin.x ,
		Transform.basis[1].dot(global_pos) + xform.origin.y,
		Transform.basis[2].dot(global_pos) + xform.origin.z
	)
func _line_plane_intersection(line_start:Vector3,line_end:Vector3,plane_at:Vector3,plane_norm:Vector3):
	round(line_start*10000)/10000
	round(line_end*10000)/10000
	var v = line_end - line_start
	var w = plane_at - line_start
	var k = w.dot(plane_norm)/v.dot(plane_norm)
	if k >= 0 and k <= 1:
		return round((line_start + k * v)*10000)/10000
	return null

